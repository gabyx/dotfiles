package swaycmd

import (
	"github.com/spf13/cobra"
)

func AddCmd(root *cobra.Command) {
	swayCmd := &cobra.Command{
		Use:   "sway",
		Short: "Sway commands.",
	}

	addAssignWorkspacesCmd(swayCmd)
	addRunInFocusedCwdCmd(swayCmd)

	root.AddCommand(swayCmd)
}
