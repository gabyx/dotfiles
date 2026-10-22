package tmuxcmd

import (
	"os"
	"slices"

	"gabyx-cli/pkg/interactive"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

// The default session name and layouts.
const defaultName = "default"

const longDescNewSession = `
    Create a new tmux session with name 'name', root directory 'root',
    session layout 'session-layout' and window layout 'window-layout'
    over 'tmuxifier'. If '--force' is given an already existing session
    is closed and reopened.
`

type newSessionArgs struct {
	force bool
}

func addNewSessionCmd(parent *cobra.Command) {
	var args newSessionArgs

	cmd := &cobra.Command{
		Use:   "new-session [name] [root] [session-layout] [window-layout]",
		Short: "Create a new tmux session over 'tmuxifier'.",
		Long:  longDescNewSession,
		Args:  cobra.MaximumNArgs(4), //nolint:mnd
		RunE: func(_cmd *cobra.Command, posArgs []string) error {
			return newSession(&args, posArgs)
		},
	}

	cmd.Flags().
		BoolVarP(&args.force,
			"force", "f", false, "Close an already existing session and reopen it.")

	parent.AddCommand(cmd)
}

func newSession(args *newSessionArgs, posArgs []string) error {
	if os.Getenv("TMUX") != "" {
		return errors.New("detach first from this session and run the command again")
	}

	cwd, err := os.Getwd()
	if err != nil {
		return err
	}

	pos := []string{defaultName, cwd, defaultName, defaultName}
	copy(pos, posArgs)
	name, root, sessionLayout, windowLayout := pos[0], pos[1], pos[2], pos[3]

	tmuxx := exec.NewCmdCtxBuilder().Quiet().Build()

	// Fails if no tmux server is running, which means no sessions exist.
	sessions, _ := tmuxx.GetSplit("tmux", "list-sessions", "-F", "#{session_name}")

	if slices.Contains(sessions, name) {
		if args.force {
			log.Info("Closing session.", "name", name)
			err = tmuxx.Check("tmux", "kill-session", "-t", name)
			if err != nil {
				return err
			}
		} else {
			log.Warnf("Session '%s' already exists. "+
				"Use 'tmuxifier load-window %s' or use '--force' to close it and reload it.",
				name, windowLayout)
		}
	}

	log.Info("Creating session.", "name", name)

	return interactive.Run(
		[]string{
			"TMUXIFIER_ROOT_DIR=" + root,
			"TMUXIFIER_SESSION_NAME=" + name,
			"TMUXIFIER_WINDOW_LAYOUT=" + windowLayout,
		},
		"tmuxifier", "load-session", sessionLayout)
}
