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

	datasetMusicInstruments = "instruments"
	datasetMusicProjects    = "projects"

	poolData        = "zfs-pool-data"
	poolMusic       = "zfs-pool-music"
	poolExternalSSD = "zfs-pool-external-ssd"
)

//nolint:gochecknoglobals // Allowed for constant definitions.
var (
	datasetNames = []string{
		datasetPersonal,
		datasetWork,
		datasetBackups,
		datasetMusicProjects,
		datasetMusicInstruments,
		datasetAll,
	}
)

type dataset struct {
	name    string
	pool    string
	dataset string
	dir     string
}

func getDatasets() map[string][]*dataset {
	return map[string][]*dataset{
		datasetWork: {{
			name:    datasetWork,
			pool:    poolData,
			dataset: datasetWork,
			dir:     "data",
		}},
		datasetPersonal: {{
			name:    datasetPersonal,
			pool:    poolData,
			dataset: datasetPersonal,
			dir:     "data",
		}},
		"music": {
			{
				name:    datasetMusicInstruments,
				pool:    poolMusic,
				dataset: datasetMusicInstruments,
				dir:     "music",
			},
			{
				name:    datasetMusicProjects,
				pool:    poolMusic,
				dataset: datasetMusicProjects,
				dir:     "music",
			},
		},
		datasetBackups: {{
			name:    datasetBackups,
			pool:    poolExternalSSD,
			dataset: "data-backups",
			dir:     "external-ssd",
		}},
	}
}

func addMountCmds(parent *cobra.Command) {
	mountCmd := &cobra.Command{
		Use:       "mount-zfs-disks [personal|work|music|backups|all]",
		Short:     "Import all ZFS pools and mount the datasets (default: 'personal').",
		Args:      cobra.MaximumNArgs(1),
		ValidArgs: datasetNames,
		RunE: func(_cmd *cobra.Command, args []string) error {
			return mountZFSDisks(args, false)
		},
	}

	unmountCmd := &cobra.Command{
		Use:       "unmount-zfs-disks [personal|work|music|backups|all]",
		Short:     "Import all ZFS pools and unmount the datasets (default: 'personal').",
		Args:      cobra.MaximumNArgs(1),
		ValidArgs: datasetNames,
		RunE: func(_cmd *cobra.Command, args []string) error {
			return mountZFSDisks(args, true)
		},
	}

	parent.AddCommand(mountCmd, unmountCmd)
}

func mountZFSDisks(keys []string, unmount bool) error {
	if len(keys) == 0 {
		keys = []string{datasetPersonal}
	} else if slices.Contains(keys, datasetAll) {
		keys = datasetNames
	}

	err := zfs.ImportAll()
	if err != nil {
		return err
	}

	for _, d := range keys {
		datasets, ok := getDatasets()[d]
		if !ok {
			return errors.New("datasets '%s' must be one of '%v'", d, datasetNames)
		}

		for _, d := range datasets {
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
	}

	return nil
}
