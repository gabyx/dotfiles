package zfs

import (
	"os"
	"path"
	"runtime"

	"gabyx-cli/pkg/sudo"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/log"
)

// Mountpoint returns the base directory where datasets are mounted.
func Mountpoint() string {
	if runtime.GOOS == "darwin" {
		return "/Volumes"
	}

	return "/mnt"
}

// IsMounted returns `true` if the dataset `pool/dataset` is mounted.
func IsMounted(pool string, dataset string) (bool, error) {
	out, err := exec.NewCmdCtxBuilder().
		Quiet().
		Build().
		Get("zfs", "get", "mounted", path.Join(pool, dataset), "-o", "value", "-H")
	if err != nil {
		return false, err
	}

	return out == "yes", nil
}

// Mount mounts the dataset `pool/dataset` at `<mountpoint>/dir/dataset`.
func Mount(pool string, dataset string, dir string) error {
	ds := path.Join(pool, dataset)

	mounted, err := IsMounted(pool, dataset)
	if err != nil {
		return err
	} else if mounted {
		log.Info("Already mounted ZFS dataset.", "dataset", ds)

		return nil
	}

	mount := path.Join(Mountpoint(), dir, dataset)
	log.Info("Mount ZFS dataset.", "dataset", ds, "mountpoint", mount)

	sudox := sudo.NewCmdCtxBuilder().Build()
	err = sudox.Check("zfs", "set", "-u", "mountpoint="+mount, ds)
	if err != nil {
		return err
	}

	err = sudox.WithStdin(os.Stdin).Check("zfs", "mount", "-l", ds)
	if err != nil {
		return errors.AddContext(err, "could not mount dataset '%s'", ds)
	}

	return nil
}

// Unmount unmounts the dataset `pool/dataset`.
func Unmount(pool string, dataset string) error {
	ds := path.Join(pool, dataset)

	mounted, err := IsMounted(pool, dataset)
	if err != nil {
		return err
	} else if !mounted {
		log.Info("Already unmounted ZFS dataset.", "dataset", ds)

		return nil
	}

	log.Info("Unmount ZFS dataset.", "dataset", ds)
	err = sudo.NewCmdCtxBuilder().Build().Check("zfs", "unmount", ds)
	if err != nil {
		return errors.AddContext(err, "could not unmount dataset '%s'", ds)
	}

	return nil
}

// ImportAll imports all ZFS pools.
func ImportAll() error {
	log.Info("Import all ZFS pools.")

	return sudo.NewCmdCtxBuilder().Build().Check("zpool", "import", "-f", "-a")
}

// PoolExists returns `true` if the pool `pool` is imported.
func PoolExists(pool string) (exists bool, err error) {
	err = exec.NewCmdCtxBuilder().
		ExitCodeHandler(exec.ExitCode0And1SuccessVar(&exists)).
		Build().
		Check("zpool", "list", "-H", "-o", "name", pool)

	return exists, err
}

// Import imports the pool `pool`.
func Import(pool string) error {
	log.Info("Import ZFS pool.", "pool", pool)

	return sudo.NewCmdCtxBuilder().Build().Check("zpool", "import", pool)
}

// CreatePool creates the pool `pool` on the vdevs `vdevs`.
// The options `opts` are passed before the pool name (e.g. `-o ashift=12`, `-O compression=lz4`).
func CreatePool(pool string, opts []string, vdevs ...string) error {
	log.Info("Create ZFS pool.", "pool", pool, "vdevs", vdevs)

	args := append([]string{"zpool", "create"}, opts...)
	args = append(args, pool)
	args = append(args, vdevs...)

	return sudo.NewCmdCtxBuilder().Build().Check(args...)
}

// DatasetExists returns `true` if the dataset `pool/dataset` exists.
func DatasetExists(pool string, dataset string) (exists bool, err error) {
	err = exec.NewCmdCtxBuilder().
		ExitCodeHandler(exec.ExitCode0And1SuccessVar(&exists)).
		Build().
		Check("zfs", "list", "-H", "-o", "name", path.Join(pool, dataset))

	return exists, err
}

// CreateDataset creates the dataset `pool/dataset` with the
// properties `props` (e.g. `recordsize=1M`).
func CreateDataset(pool string, dataset string, props ...string) error {
	ds := path.Join(pool, dataset)
	log.Info("Create ZFS dataset.", "dataset", ds, "properties", props)

	args := []string{"zfs", "create"}
	for _, p := range props {
		args = append(args, "-o", p)
	}
	args = append(args, ds)

	return sudo.NewCmdCtxBuilder().Build().Check(args...)
}

// MountAt sets the mountpoint of the dataset `pool/dataset` permanently to
// `mountpoint` and mounts it if not yet mounted.
func MountAt(pool string, dataset string, mountpoint string) error {
	ds := path.Join(pool, dataset)
	sudox := sudo.NewCmdCtxBuilder().Build()

	err := sudox.Check("zfs", "set", "mountpoint="+mountpoint, ds)
	if err != nil {
		return err
	}

	mounted, err := IsMounted(pool, dataset)
	if err != nil || mounted {
		return err
	}

	log.Info("Mount ZFS dataset.", "dataset", ds, "mountpoint", mountpoint)

	return sudox.Check("zfs", "mount", ds)
}
