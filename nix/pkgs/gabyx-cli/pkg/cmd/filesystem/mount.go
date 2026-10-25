package filesystemcmd

import (
	"maps"
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

	DatasetMusicInstruments = "instruments"
	DatasetMusicProjects    = "projects"
	DatasetMusicCollection  = "collections"

	poolData        = "zfs-pool-data"
	poolMusic       = "zfs-pool-music"
	poolExternalSSD = "zfs-pool-external-ssd"
)

type dataset struct {
	name    string
	pool    string
	dataset string
	dir     string
}

// datasetKeys returns the sorted keys of `getDatasets`.
func datasetKeys() []string {
	return slices.Sorted(maps.Keys(getDatasets()))
}

// datasetNames returns all valid arguments: the keys of `getDatasets` and `all`.
func datasetNames() []string {
	return append(datasetKeys(), datasetAll)
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
				name:    DatasetMusicInstruments,
				pool:    poolMusic,
				dataset: DatasetMusicInstruments,
				dir:     "music",
			},
			{
				name:    DatasetMusicProjects,
				pool:    poolMusic,
				dataset: DatasetMusicProjects,
				dir:     "music",
			},
			{
				name:    DatasetMusicCollection,
				pool:    poolMusic,
				dataset: DatasetMusicCollection,
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
		ValidArgs: datasetNames(),
		RunE: func(_cmd *cobra.Command, args []string) error {
			return mountZFSDisks(args, false)
		},
	}

	unmountCmd := &cobra.Command{
		Use:       "unmount-zfs-disks [personal|work|music|backups|all]",
		Short:     "Import all ZFS pools and unmount the datasets (default: 'personal').",
		Args:      cobra.MaximumNArgs(1),
		ValidArgs: datasetNames(),
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
		keys = datasetKeys()
	}

	err := zfs.ImportAll()
	if err != nil {
		return err
	}

	for _, d := range keys {
		datasets, ok := getDatasets()[d]
		if !ok {
			return errors.New("datasets '%s' must be one of '%v'", d, datasetNames())
		}

		for _, d := range datasets {
			e := zfs.Unmount(d.pool, d.dataset)
			if e != nil {
				err = errors.Combine(err, e)
				log.WarnE(err, "Could not unmount dataset. Continue", "dataset", d.name)
			}

			if unmount {
				continue
			}

			e = zfs.Mount(d.pool, d.dataset, d.dir)
			if e != nil {
				log.WarnE(err, "Could not mount dataset. Continue", "dataset", d.name)
				err = errors.Combine(err, e)
			}
		}
	}

	return err
}
