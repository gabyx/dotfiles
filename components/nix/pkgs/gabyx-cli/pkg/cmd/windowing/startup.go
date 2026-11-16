package windowingcmd

import (
	"os"
	"time"

	gexec "gabyx-cli/pkg/exec"

	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

const (
	// Wait time before the startup runs.
	startupDelay = 500 * time.Millisecond
	// Wait time after starting the tmux server, so `tmux-resurrect` can restore sessions.
	tmuxServerDelay = 4 * time.Second
)

type startupArgs struct {
	tmux    bool
	logFile string
}

// tmuxWorkspace is a tmux session started in a terminal on a Sway workspace.
type tmuxWorkspace struct {
	session   string
	workspace string
}

func addStartupCmd(parent *cobra.Command) {
	var args startupArgs

	cmd := &cobra.Command{
		Use:   "startup",
		Short: "Run the startup tasks of Sway (also used by Hyprland).",
		Long: `
    Without '--tmux' only a notification is sent.
    With '--tmux' the tmux server is started, the tmux sessions are created
    and a terminal for each is started on its workspace.
    All output (also of the started commands) is written to 'log-file'.
`,
		Args: cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			return startup(&args)
		},
	}

	cmd.Flags().
		BoolVar(&args.tmux, "tmux", false, "Start tmux and a terminal for each tmux session.")

	parent.AddCommand(cmd)
}

// tmuxWorkspaces returns the tmux sessions and their workspaces.
// The last workspace is focused at the end.
func tmuxWorkspaces() []tmuxWorkspace {
	return []tmuxWorkspace{
		{session: "Main-1", workspace: "$ws-3"},
		{session: "Main-2", workspace: "$ws-4"},
	}
}

func startup(args *startupArgs) error {
	time.Sleep(startupDelay)

	if !args.tmux {
		_ = exec.NewCommandCtx(".").Check(
			gexec.ExtCmdNotifySend, "Using wezterm: not starting tmux")
		log.Info("Finished.")

		return nil
	}

	err := startTmux()
	if err != nil {
		return err
	}

	log.Info("Finished.")

	return nil
}

// startTmux starts the tmux server, creates the sessions and starts
// a terminal for each session on its workspace.
func startTmux() error {
	log.Info("Start tmux, let it recreate the sessions with resurrect.",
		"TMUX_TMPDIR", os.Getenv("TMUX_TMPDIR"))

	tmux := exec.NewCommandCtx(".")

	err := tmux.Check(gexec.ExtCmdTmux, "start-server")
	if err != nil {
		return err
	}

	_ = tmux.Check(gexec.ExtCmdTmux, "display-message", "-p", "Tmux: socket path: #{socket_path}")
	time.Sleep(tmuxServerDelay)

	_, err = tmux.GetSplit(gexec.ExtCmdTmux, "list-sessions")
	if err != nil {
		log.ErrorE(
			err,
			"No sessions: is 'exit-empty' not set to 'off', so the server exits directly?",
		)
	}

	// Create all sessions which do not exist yet.
	for _, w := range tmuxWorkspaces() {
		if tmux.Check(gexec.ExtCmdTmux, "has-session", "-t", "="+w.session) == nil {
			continue
		}

		err = tmux.Check(gexec.ExtCmdTmux, "new-session", "-d", "-s", w.session)
		if err != nil {
			return err
		}
	}

	sessions, err := tmux.GetSplit(gexec.ExtCmdTmux, "list-sessions")
	if err != nil {
		log.ErrorE(err, "Sessions should now be available.")
	}

	log.Info("Sessions created.", "sessions", sessions)

	for _, w := range tmuxWorkspaces() {
		log.Info("Start terminal.", "session", w.session, "workspace", w.workspace)

		err = exec.NewCommandCtx(".").Check(gexec.ExtCmdSwaymsg,
			"workspace "+w.workspace+"; exec gabyx term start-into-tmux "+w.session)
		if err != nil {
			return err
		}
	}

	return nil
}
