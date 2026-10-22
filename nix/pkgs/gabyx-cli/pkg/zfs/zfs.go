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
