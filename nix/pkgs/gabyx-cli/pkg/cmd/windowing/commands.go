package windowingcmd

import (
	gexec "gabyx-cli/pkg/exec"
	"gabyx-cli/pkg/interactive"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/spf13/cobra"
)

// command is a windowing command used in the window manager configs
// (Sway, Niri, Hyprland) and Waybar.
// It runs either a `gabyx` command in this process or replaces this process
// with an external program.
// Arguments of the windowing command are appended.
type command struct {
	name  string
	short string

	gabyx []string // Path and arguments of a `gabyx` command, e.g. `rofi launcher`.
	exe   []string // External program and its arguments.
}

func commands() []command {
	gabyx := func(name, short string, args ...string) command {
		return command{name: name, short: short, gabyx: args, exe: nil}
	}
	exe := func(name, short string, args ...string) command {
		return command{name: name, short: short, gabyx: nil, exe: args}
	}

	return []command{
		gabyx("file-manager", "Start the file manager.", "term", "start", "lf"),

		gabyx("launcher-menu", "Show the launcher menu.", "rofi", "launcher"),
		gabyx("power-menu", "Show the power menu.", "rofi", "power"),
		gabyx("wireless-menu", "Show the wireless menu.", "rofi", "network", "wireless"),
		gabyx("network-menu", "Show the network editor.", "rofi", "network", "editor"),
		exe("bluetooth-menu", "Show the bluetooth menu.", gexec.ExtCmdRofiBluetooth),
		gabyx("emoji-menu", "Show the emoji menu.", "rofi", "emoji"),
		gabyx("systemd-menu", "Show the systemd menu.", "rofi", "systemd"),
		gabyx("passwdmgr-menu", "Show the password manager menu.", "rofi", "password"),
		gabyx("procs-menu", "Show the process viewer.", "term", "start", "btop"),
		exe("sound-menu", "Show the sound settings.", gexec.ExtCmdPavucontrol),
		exe("calculator-menu", "Show the calculator.", gexec.ExtCmdQalculateGtk),
		gabyx("screenshot-menu", "Show the screenshot menu.", "rofi", "screenshot"),
		gabyx("screenrecord-menu", "Show the screen recording menu.", "rofi", "screenrecord"),
		gabyx("color-picker-menu", "Show the color picker.", "rofi", "color-picker"),
		exe("copy-menu", "Show the clipboard history.", gexec.ExtCmdCopyq, "toggle"),

		exe("brightness-up", "Increase the brightness.", gexec.ExtCmdBrightnessctl, "set", "10%+"),
		exe("brightness-down", "Decrease the brightness.", gexec.ExtCmdBrightnessctl, "set", "10%-"),

		exe("clipboard", "Start the clipboard manager.", gexec.ExtCmdCopyq, "--start-server"),
		exe("clipboard-menu", "Show the clipboard history.", gexec.ExtCmdCopyq, "toggle"),

		exe("notifications", "Start the notification daemon.", gexec.ExtCmdSwaync),
		exe("notification-menu", "Show the notification center.", gexec.ExtCmdSwayncClient, "-t", "-sw"),

		exe("nightshifter", "Start the night shift indicator.", gexec.ExtCmdGammastepIndicator),
	}
}

func addCommands(parent *cobra.Command) {
	for _, c := range commands() {
		parent.AddCommand(&cobra.Command{
			Use:   c.name + " [args...]",
			Short: c.short,
			// All arguments are passed to the command.
			DisableFlagParsing: true,
			RunE: func(cmd *cobra.Command, args []string) error {
				if c.gabyx != nil {
					return runGabyx(
						cmd.Root(),
						append(c.gabyx, args...))
				}

				return interactive.Exec(nil, append(c.exe, args...)...)
			},
		})
	}
}

// runGabyx runs the `gabyx` command with path and arguments `args`
// in this process.
func runGabyx(root *cobra.Command, args []string) error {
	target, rest, err := findGabyx(root, args)
	if err != nil {
		return err
	}

	if !target.DisableFlagParsing {
		err = target.ParseFlags(rest)
		if err != nil {
			return err
		}

		rest = target.Flags().Args()
	}

	err = target.ValidateArgs(rest)
	if err != nil {
		return err
	}

	if target.PreRunE != nil {
		err = target.PreRunE(target, rest)
		if err != nil {
			return err
		}
	}

	return target.RunE(target, rest)
}

// findGabyx returns the runnable `gabyx` command for `args` and the remaining arguments.
func findGabyx(root *cobra.Command, args []string) (*cobra.Command, []string, error) {
	target, rest, err := root.Find(args)
	if err != nil {
		return nil, nil, errors.AddContext(err, "could not find command '%v'", args)
	}

	if target == root || target.RunE == nil {
		return nil, nil, errors.New("command '%v' is not runnable", args)
	}

	return target, rest, nil
}
