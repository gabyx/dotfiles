package musiccmd

import (
	"github.com/spf13/cobra"
)

func AddCmd(root *cobra.Command) {
	musicCmd := &cobra.Command{
		Use:   "music",
		Short: "Music commands.",
	}

	addCreateZfsMusicCmd(musicCmd)

	root.AddCommand(musicCmd)
}
