package roficmd

import (
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

func addPowerCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "power",
		Short: "Show the power menu (over 'rofi-power-menu').",
		Args:  cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			return exec.NewCommandCtx(".").
				Check("rofi", "-show", "menu",
					"-modi", "menu:rofi-power-menu --symbols-font 'JetBrainsMono Nerd Font'")
		},
	})
}
