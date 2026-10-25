package musiccmd

import (
	"context"
	"fmt"
	"os"
	"path"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"

	filesystemcmd "gabyx-cli/pkg/cmd/filesystem"
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
    With '--format' the disk or partition 'disk' is shown with 'lsblk' and, after a
    confirmation, a new pool is created on it ('zpool create -f').
    Without '--format' the existing pool is imported.
    With '--setup' all instruments which are not yet present below
    '<mount>/instruments' are downloaded and extracted.
`

const datasetInstruments = filesystemcmd.DatasetMusicInstruments

type createZfsMusicArgs struct {
	disk   string
	mount  string
	pool   string
	format bool
	force  bool
	setup  bool
}

func musicDatasets() []string {
	return []string{
		filesystemcmd.DatasetMusicInstruments,
		filesystemcmd.DatasetMusicCollection,
		filesystemcmd.DatasetMusicProjects,
	}
}

// datasetProps returns the properties of all datasets.
// Large records: audio files are large and read sequentially.
func datasetProps() []string {
	return []string{"recordsize=1M"}
}

func poolOpts() []string {
	return []string{
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
}

func addCreateZfsMusicCmd(parent *cobra.Command) {
	var args createZfsMusicArgs

	cmd := &cobra.Command{
		Use:   "create-zfs-music",
		Short: "Create or import the ZFS music pool, its datasets and install instruments.",
		Long:  longDescCreateZfsMusic,
		Args:  cobra.NoArgs,
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
		StringVarP(&args.disk, "disk", "d", "", "The disk or partition to format (e.g. '/dev/disk/by-id/...').")
	cmd.Flags().
		StringVarP(&args.mount, "mount", "m", "/mnt/music", "The directory where the datasets are mounted.")
	cmd.Flags().
		StringVarP(&args.pool, "pool", "p", "zfs-pool-music", "The name of the ZFS pool.")
	cmd.Flags().
		BoolVar(&args.format, "format", false, "Erase the disk and create a new pool.")
	cmd.Flags().
		BoolVar(&args.force, "force", false,
			"Do not ask for confirmation before formatting.")
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

	for _, ds := range musicDatasets() {
		err = setupDataset(args.pool, ds, path.Join(args.mount, ds))
		if err != nil {
			return err
		}
	}

	if !args.setup {
		return nil
	}

	return installInstruments(ctx, path.Join(args.mount, datasetInstruments), instruments)
}

func importPool(pool string) error {
	exists, err := zfs.PoolExists(pool)
	if err != nil || exists {
		log.Infof("Pool '%v' already exists.", pool)
		return err
	}

	log.Info("Import pool '%s'.", pool)
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

	if !args.force {
		ok, e := confirmFormat(disk, args.pool)
		if e != nil {
			return e
		} else if !ok {
			return errors.New("aborted by the user")
		}
	}

	// `-f`: Overwrite existing filesystems or partition tables on the device.
	return zfs.CreatePool(args.pool, append([]string{"-f"}, poolOpts()...), disk)
}

// checkDisk returns an error if `disk` is not a whole disk or a partition or if
// any filesystem on it is mounted.
func checkDisk(disk string) error {
	lsblk := exec.NewCmdCtxBuilder().Quiet().Build()

	typ, err := lsblk.Get("lsblk", "--nodeps", "--noheadings", "--output", "TYPE", disk)
	if err != nil {
		return err
	} else if typ != "disk" && typ != "part" {
		return errors.New("'%s' is not a disk or partition but type '%s'", disk, typ)
	}

	mounts, err := lsblk.Get("lsblk", "--noheadings", "--raw", "--output", "MOUNTPOINTS", disk)
	if err != nil {
		return err
	} else if strings.TrimSpace(mounts) != "" {
		return errors.New("'%s' has mounted filesystems:\n%s", disk, mounts)
	}

	return nil
}

func confirmFormat(disk string, pool string) (ok bool, err error) {
	// For a partition show its whole disk (`PKNAME`, empty for a disk):
	// the model and serial are only set on the disk.
	parent, err := exec.NewCommandCtx(".").
		Get("lsblk", "--nodeps", "--noheadings", "--paths", "--output", "PKNAME", disk)
	if err != nil {
		return false, err
	} else if parent == "" {
		parent = disk
	}

	info, err := exec.NewCommandCtx(".").
		Get("lsblk", "--paths", "--output", "NAME,SIZE,TYPE,MODEL,SERIAL,FSTYPE,LABEL,MOUNTPOINTS", parent)
	if err != nil {
		return false, err
	}

	retryMsg := ""

	for range 2 {
		confirm := huh.NewConfirm().
			Title(fmt.Sprintf("%sErase all data on '%s' and create pool '%s'?", retryMsg, disk, pool)).
			Description(info + "\n\nDevice: " + disk + "\nDisk:   " + parent).
			Affirmative("Erase").
			Negative("Abort").
			Value(&ok)

		err = huh.NewForm(huh.NewGroup(confirm)).
			WithOutput(os.Stderr).
			Run()
		if err != nil || !ok {
			return false, err
		}

		retryMsg = "ARE YOU REALLY SURE? :"
	}

	return ok, err
}

// setupDataset creates the dataset `pool/dataset` if it does not exist,
// mounts it at `mountpoint` and gives it to the current user.
func setupDataset(pool string, dataset string, mountpoint string) error {
	exists, err := zfs.DatasetExists(pool, dataset)
	if err != nil {
		return err
	}

	if !exists {
		err = zfs.CreateDataset(pool, dataset, datasetProps()...)
		if err != nil {
			return err
		}
	} else {
		log.Infof("Dataset '%s' already exists.", dataset)
	}

	log.Infof("Mount dataset '%s'.", dataset)
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

	return sudo.NewCommandCtx(".").Check("chown", strconv.Itoa(uid)+":"+strconv.Itoa(gid), dir)
}
