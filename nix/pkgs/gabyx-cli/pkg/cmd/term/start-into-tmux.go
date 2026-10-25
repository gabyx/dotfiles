package termcmd

import (
	"gabyx-cli/pkg/interactive"

	"github.com/spf13/cobra"
)

func addStartIntoTmuxCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use: "start-into-tmux <session> [args...]",
		Short: "Start a new terminal whose shell enters the tmux session 'session' " +
			"('args' are passed to the terminal).",
		Long: `
    Starts the terminal with 'RUN_TMUX=true' and 'RUN_TMUX_SESSION_ID=<session>'.
    The shell ('~/.zshrc-tmux.zsh') then creates or attaches to the tmux session.
    An empty 'session' starts the terminal without tmux.
`,
		Args: cobra.MinimumNArgs(1),
		// All arguments after `session` belong to the terminal.
		DisableFlagParsing: true,
		RunE: func(_cmd *cobra.Command, args []string) error {
			return interactive.Exec(
				tmuxEnv(args[0]),
				terminalCmd(args[1:]...)...)
		},
	})
}

// tmuxEnv returns the environment variables for the shell to enter
// the tmux session `session`.
func tmuxEnv(session string) []string {
	if session == "" {
		return nil
	}

	return []string{"RUN_TMUX=true", "RUN_TMUX_SESSION_ID=" + session}
}
