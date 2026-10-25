package roficmd

import (
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

func addSystemdCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "systemd [args...]",
		Short: "Show the systemd units menu (over 'rofi-systemd') with 'args'.",
		Args:  cobra.ArbitraryArgs,
		RunE: func(_cmd *cobra.Command, args []string) error {
			return exec.NewCmdCtxBuilder().
				Env("ROFI_SYSTEMD_TERM=wezterm start").
				Build().
				Check(append([]string{"rofi-systemd"}, args...)...)
		},
	})
}
