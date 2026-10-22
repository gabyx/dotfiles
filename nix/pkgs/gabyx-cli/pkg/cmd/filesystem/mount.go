package filesystemcmd

import (
	"slices"

	"gabyx-cli/pkg/zfs"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

const (
	datasetWork     = "work"
	datasetPersonal = "personal"
	datasetBackups  = "backups"
	datasetAll      = "all"

	poolData        = "zfs-pool-data"
	poolExternalSSD = "zfs-pool-external-ssd"
)

//nolint:gochecknoglobals // Allowed for constant definitions.
var (
	datasets = []dataset{
		{name: datasetWork, pool: poolData, dataset: datasetWork, dir: "data"},
		{name: datasetPersonal, pool: poolData, dataset: datasetPersonal, dir: "data"},
		{name: datasetBackups, pool: poolExternalSSD, dataset: "data-backups", dir: "external-ssd"},
	}

	datasetNames = []string{datasetPersonal, datasetWork, datasetBackups, datasetAll}
)

type dataset struct {
	name    string
	pool    string
	dataset string
	dir     string
}

func addMountCmds(parent *cobra.Command) {
	mountCmd := &cobra.Command{
		Use:       "mount-zfs-disks [personal|work|backups|all]",
		Short:     "Import all ZFS pools and mount the datasets (default: 'personal').",
		Args:      cobra.MaximumNArgs(1),
		ValidArgs: datasetNames,
		RunE: func(_cmd *cobra.Command, args []string) error {
			return mountZFSDisks(args, false)
		},
	}

	unmountCmd := &cobra.Command{
		Use:       "unmount-zfs-disks [personal|work|backups|all]",
		Short:     "Import all ZFS pools and unmount the datasets (default: 'personal').",
		Args:      cobra.MaximumNArgs(1),
		ValidArgs: datasetNames,
		RunE: func(_cmd *cobra.Command, args []string) error {
			return mountZFSDisks(args, true)
		},
	}

	parent.AddCommand(mountCmd, unmountCmd)
}

func mountZFSDisks(args []string, unmount bool) error {
	what := datasetPersonal
	if len(args) > 0 {
		what = args[0]
	}

	if !slices.Contains(datasetNames, what) {
		return errors.New("datasets '%s' must be one of '%v'", what, datasetNames)
	}

	err := zfs.ImportAll()
	if err != nil {
		return err
	}

	for _, d := range datasets {
		if what != datasetAll && what != d.name {
			continue
		}

		err = zfs.Unmount(d.pool, d.dataset)
		if err != nil {
			log.WarnE(err, "Could not unmount dataset.", "dataset", d.name)
		}

		if unmount {
			continue
		}

		err = zfs.Mount(d.pool, d.dataset, d.dir)
		if err != nil {
			return err
		}
	}

	return nil
}
