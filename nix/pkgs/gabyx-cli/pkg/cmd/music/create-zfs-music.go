package musiccmd

import (
	"context"
	"os"
	"path/filepath"
	"slices"
	"strconv"
	"strings"
	"syscall"

	"gabyx-cli/pkg/sudo"
	"gabyx-cli/pkg/zfs"

	"charm.land/huh/v2"
	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

const longDescCreateZfsMusic = `
    Create or import the ZFS pool for music and create the datasets
    'instruments' and 'projects' mounted at '<mount>/<dataset>'.
    With '--format' the disk 'disk' is shown with 'lsblk' and, after a
    confirmation, all signatures are erased ('wipefs -a') and a new pool is created.
    Without '--format' the existing pool is imported.
    With '--setup' all instruments which are not yet present below
    '<mount>/instruments' are downloaded and extracted.
`

const datasetInstruments = "instruments"

//nolint:gochecknoglobals // Allowed for constant definitions.
var (
	musicDatasets = []string{datasetInstruments, "projects"}

	// Properties of all datasets.
	// Large records: audio files are large and read sequentially.
	datasetProps = []string{"recordsize=1M"}

	poolOpts = []string{
		"-o",
		"ashift=12", // 4 KiB minimum block size, usual for SSDs.
		"-o",
		"autotrim=on", // TRIM freed blocks continuously.
		"-O",
		"compression=lz4", // Audio compresses little, lz4 aborts early on incompressible data.
		"-O",
		"atime=off", // Reading a file does not write an access-time update.
		"-O",
		"xattr=sa", // Store extended attributes in the inode.
		"-O",
		"dnodesize=auto", // Larger dnodes so `xattr=sa` attributes fit in the inode.
		"-O",
		"normalization=formD", // Filename lookup ignores NFC/NFD differences (macOS vs. Linux).
		"-O",
		"mountpoint=none", // Only the datasets are mounted.
	}
)

type createZfsMusicArgs struct {
	disk   string
	mount  string
	pool   string
	format bool
	force  bool
	setup  bool
}

func addCreateZfsMusicCmd(parent *cobra.Command) {
	var args createZfsMusicArgs

	cmd := &cobra.Command{
		Use:   "create-zfs-music",
		Short: "Create or import the ZFS music pool, its datasets and install instruments.",
		Long:  longDescCreateZfsMusic,
		Example: "  gabyx music create-zfs-music --disk /dev/disk/by-id/XXX --format --setup\n" +
			"  gabyx music create-zfs-music --setup",
		Args: cobra.NoArgs,
		PreRunE: func(_cmd *cobra.Command, _args []string) error {
			if args.format && args.disk == "" {
				return errors.New("'--format' needs '--disk'")
			}

			return nil
		},
		RunE: func(cmd *cobra.Command, _args []string) error {
			return createZfsMusic(cmd.Context(), &args)
		},
	}

	cmd.Flags().
		StringVarP(&args.disk, "disk", "d", "", "The disk to format (e.g. '/dev/disk/by-id/...').")
	cmd.Flags().
		StringVarP(&args.mount, "mount", "m", "/mnt/music", "The directory where the datasets are mounted.")
	cmd.Flags().
		StringVarP(&args.pool, "pool", "p", "zfs-pool-music", "The name of the ZFS pool.")
	cmd.Flags().
		BoolVar(&args.format, "format", false, "Erase the disk and create a new pool.")
	cmd.Flags().
		BoolVarP(&args.force, "force", "f", false,
			"Do not ask for confirmation and pass '-f' to 'zpool create'.")
	cmd.Flags().
		BoolVar(&args.setup, "setup", true, "Download and extract missing instruments.")

	parent.AddCommand(cmd)
}

func createZfsMusic(ctx context.Context, args *createZfsMusicArgs) error {
	var err error
	if args.format {
		err = formatDisk(args)
	} else {
		err = importPool(args.pool)
	}

	if err != nil {
		return err
	}

	for _, ds := range musicDatasets {
		err = setupDataset(args.pool, ds, filepath.Join(args.mount, ds))
		if err != nil {
			return err
		}
	}

	if !args.setup {
		return nil
	}

	return installInstruments(ctx, filepath.Join(args.mount, datasetInstruments), instruments)
}

func importPool(pool string) error {
	exists, err := zfs.PoolExists(pool)
	if err != nil || exists {
		return err
	}

	err = zfs.Import(pool)
	if err != nil {
		return errors.AddContext(
			err,
			"could not import pool '%s', use '--format' to create it",
			pool,
		)
	}

	return nil
}

func formatDisk(args *createZfsMusicArgs) error {
	disk, err := filepath.EvalSymlinks(args.disk)
	if err != nil {
		return err
	}

	err = checkDisk(disk)
	if err != nil {
		return err
	}

	exists, err := zfs.PoolExists(args.pool)
	if err != nil {
		return err
	} else if exists {
		return errors.New("pool '%s' is imported, destroy or export it first", args.pool)
	}

	vdev := diskByID(disk)

	if !args.force {
		ok, e := confirmFormat(disk, vdev, args.pool)
		if e != nil {
			return e
		} else if !ok {
			return errors.New("aborted by the user")
		}
	}

	err = wipeDisk(disk)
	if err != nil {
		return err
	}

	opts := poolOpts
	if args.force {
		opts = append([]string{"-f"}, opts...)
	}

	return zfs.CreatePool(args.pool, opts, vdev)
}

// checkDisk returns an error if `disk` is not a whole disk or if
// any filesystem on it is mounted.
func checkDisk(disk string) error {
	lsblk := exec.NewCmdCtxBuilder().Quiet().Build()

	typ, err := lsblk.Get("lsblk", "--nodeps", "--noheadings", "--output", "TYPE", disk)
	if err != nil {
		return err
	} else if typ != "disk" {
		return errors.New("'%s' is not a whole disk but type '%s'", disk, typ)
	}

	mounts, err := lsblk.Get("lsblk", "--noheadings", "--raw", "--output", "MOUNTPOINTS", disk)
	if err != nil {
		return err
	} else if strings.TrimSpace(mounts) != "" {
		return errors.New("'%s' has mounted filesystems:\n%s", disk, mounts)
	}

	return nil
}

// diskByID returns the `/dev/disk/by-id` path of `disk`.
// IDs with the model and serial (e.g. `ata-...`) are preferred over `wwn-...`.
// If none is found `disk` is returned.
func diskByID(disk string) string {
	const dir = "/dev/disk/by-id"

	entries, err := os.ReadDir(dir)
	if err != nil {
		return disk
	}

	var ids []string
	for _, e := range entries {
		p := filepath.Join(dir, e.Name())
		if target, e := filepath.EvalSymlinks(p); e == nil && target == disk {
			ids = append(ids, p)
		}
	}

	if len(ids) == 0 {
		return disk
	}

	slices.SortFunc(ids, func(a, b string) int {
		aWWN := strings.HasPrefix(filepath.Base(a), "wwn-")
		bWWN := strings.HasPrefix(filepath.Base(b), "wwn-")

		switch {
		case aWWN == bWWN:
			return strings.Compare(a, b)
		case aWWN:
			return 1
		default:
			return -1
		}
	})

	return ids[0]
}

func confirmFormat(disk string, vdev string, pool string) (ok bool, err error) {
	info, err := exec.NewCommandCtx(".").
		Get("lsblk", "--output", "NAME,SIZE,TYPE,MODEL,SERIAL,FSTYPE,LABEL,MOUNTPOINTS", disk)
	if err != nil {
		return false, err
	}

	confirm := huh.NewConfirm().
		Title("Erase all data on '" + disk + "' and create pool '" + pool + "'?").
		Description(info + "\n\nDevice: " + vdev).
		Affirmative("Erase").
		Negative("Abort").
		Value(&ok)

	err = huh.NewForm(huh.NewGroup(confirm)).
		WithOutput(os.Stderr).
		Run()

	return ok, err
}

// wipeDisk erases all signatures on all partitions of `disk` and then on `disk`.
// Partitions are wiped first, they are not accessible anymore after
// the partition table is erased.
func wipeDisk(disk string) error {
	lines, err := exec.NewCommandCtx("").
		GetSplit("lsblk", "--noheadings", "--raw", "--paths", "--output", "NAME,TYPE", disk)
	if err != nil {
		return err
	}

	var devices []string
	for _, l := range lines {
		if f := strings.Fields(l); len(f) == 2 && f[1] == "part" {
			devices = append(devices, f[0])
		}
	}
	devices = append(devices, disk)

	sudox := sudo.NewCmdCtxBuilder().Build()
	for _, d := range devices {
		log.Info("Erase all signatures.", "device", d)

		err = sudox.Check("wipefs", "--all", d)
		if err != nil {
			return err
		}
	}

	return nil
}

// setupDataset creates the dataset `pool/dataset` if it does not exist,
// mounts it at `mountpoint` and gives it to the current user.
func setupDataset(pool string, dataset string, mountpoint string) error {
	exists, err := zfs.DatasetExists(pool, dataset)
	if err != nil {
		return err
	}

	if !exists {
		err = zfs.CreateDataset(pool, dataset, datasetProps...)
		if err != nil {
			return err
		}
	}

	err = zfs.MountAt(pool, dataset, mountpoint)
	if err != nil {
		return err
	}

	return chownToUser(mountpoint)
}

// chownToUser changes the owner of `dir` to the current user if needed.
func chownToUser(dir string) error {
	info, err := os.Stat(dir)
	if err != nil {
		return err
	}

	uid, gid := os.Getuid(), os.Getgid()
	if st, ok := info.Sys().(*syscall.Stat_t); ok && int(st.Uid) == uid {
		return nil
	}

	log.Info("Change owner to current user.", "dir", dir)

	return sudo.NewCmdCtxBuilder().
		Build().
		Check("chown", strconv.Itoa(uid)+":"+strconv.Itoa(gid), dir)
}
