package windowingcmd

import (
	"os"

	gexec "gabyx-cli/pkg/exec"
	"gabyx-cli/pkg/interactive"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

// Environment variable with the window manager (`sway`, `niri` or `hyprland`),
// set in `nix/nixos/windowing.nix`.
const envWindowManager = "XDG_SESSION_DESKTOP"

const (
	wmSway     = "sway"
	wmNiri     = "niri"
	wmHyprland = "hyprland"
)

func addDisplayManagerCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "display-manager [args...]",
		Short: "Start the display manager ('way-displays' on Sway and Niri).",
		// All arguments are passed to the display manager.
		DisableFlagParsing: true,
		RunE: func(_cmd *cobra.Command, args []string) error {
			wm := strings.ToLower(os.Getenv(envWindowManager))

			switch wm {
			case wmSway, wmNiri:
				return interactive.Exec(nil, append([]string{gexec.ExtCmdWayDisplays}, args...)...)
			default:
				return die("No display manager defined for window manager '%s'.", wm)
			}
		},
	})
}

func addWindowMgrExecCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "mgr-exec <command> [args...]",
		Short: "Execute 'command' over the window manager (e.g. 'swaymsg exec').",
		Args:  cobra.MinimumNArgs(1),
		// All arguments are passed to the window manager.
		DisableFlagParsing: true,
		RunE: func(_cmd *cobra.Command, args []string) error {
			wmArgs, err := windowMgrExecArgs(strings.ToLower(os.Getenv(envWindowManager)))
			if err != nil {
				return die("%s", err.Error())
			}

			return interactive.Exec(nil, append(wmArgs, args...)...)
		},
	})
}

// windowMgrExecArgs returns the command of the window manager `wm`
// to execute a command.
func windowMgrExecArgs(wm string) ([]string, error) {
	switch strings.ToLower(wm) {
	case wmSway:
		return []string{gexec.ExtCmdSwaymsg, "exec"}, nil
	case wmNiri:
		return []string{gexec.ExtCmdNiri, "msg", "action", "spawn", "--"}, nil
	case wmHyprland:
		return []string{gexec.ExtCmdHyprctl, "dispatch", "exec"}, nil
	default:
		return nil, errors.New(
			"window manager '%s' (env. '%s') is not defined",
			wm,
			envWindowManager,
		)
	}
}

// die sends a warning notification and returns the error.
func die(format string, args ...any) error {
	err := errors.New(format, args...)
	log.ErrorE(err, "Error ocured.")
	_ = exec.NewCommandCtx(".").Check(gexec.ExtCmdNotifySend, "--category", "warning", err.Error())

	return err
}
