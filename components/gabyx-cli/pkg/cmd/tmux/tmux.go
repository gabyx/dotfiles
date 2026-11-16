package tmuxcmd

import (
	"github.com/spf13/cobra"
)

func AddCmd(root *cobra.Command) {
	tmuxCmd := &cobra.Command{
		Use:   "tmux",
		Short: "Tmux commands.",
	}

	addResurrectRestoreCmd(tmuxCmd)
	addNewSessionCmd(tmuxCmd)

	root.AddCommand(tmuxCmd)
}
