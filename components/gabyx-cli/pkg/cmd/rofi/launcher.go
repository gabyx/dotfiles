package roficmd

import (
	gexec "gabyx-cli/pkg/exec"

	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

func addLauncherCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "launcher",
		Short: "Show the application launcher menu.",
		Args:  cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			return exec.NewCommandCtx(".").
				Check(gexec.ExtCmdRofi, "-modi", "run,drun,window", "-show", "drun", "-show-icons")
		},
	})
}
