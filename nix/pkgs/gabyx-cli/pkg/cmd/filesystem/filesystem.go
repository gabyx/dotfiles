package filesystemcmd

import (
	"github.com/spf13/cobra"
)

func AddCmd(root *cobra.Command) {
	fsCmd := &cobra.Command{
		Use:     "filesystem",
		Aliases: []string{"fs"},
		Short:   "Filesystem and ZFS commands.",
	}

	addFindRecentCmd(fsCmd)
	addMountCmds(fsCmd)

	root.AddCommand(fsCmd)
}
