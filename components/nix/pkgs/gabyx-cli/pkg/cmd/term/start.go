package termcmd

import (
	"gabyx-cli/pkg/interactive"

	"github.com/spf13/cobra"
)

func addStartCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "start [args...]",
		Short: "Start a new terminal in the current directory ('args' are passed to the terminal).",
		// All arguments belong to the terminal.
		DisableFlagParsing: true,
		RunE: func(_cmd *cobra.Command, args []string) error {
			return interactive.Exec(nil, terminalCmd(args...)...)
		},
	})
}
