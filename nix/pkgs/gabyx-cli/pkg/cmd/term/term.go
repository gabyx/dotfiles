package termcmd

import (
	gexec "gabyx-cli/pkg/exec"

	"github.com/spf13/cobra"
)

func AddCmd(root *cobra.Command) {
	termCmd := &cobra.Command{
		Use:   "term",
		Short: "Terminal commands.",
	}

	addStartCmd(termCmd)
	addStartIntoTmuxCmd(termCmd)

	root.AddCommand(termCmd)
}

// terminalCmd returns the command to start a new terminal in the current
// directory with the arguments `args` (e.g. a program to run).
func terminalCmd(args ...string) []string {
	return append([]string{gexec.ExtCmdWezterm, "start", "--always-new-process", "--cwd", "."}, args...)
}
