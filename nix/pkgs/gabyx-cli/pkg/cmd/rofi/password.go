package roficmd

import (
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

func addPasswordCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "password",
		Short: "Show the password manager menu ('rofi-rbw' for Bitwarden).",
		Args:  cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			return exec.NewCommandCtx(".").Check("rofi-rbw")
		},
	})
}
