package roficmd

import (
	osexec "os/exec"
	"strings"

	gexec "gabyx-cli/pkg/exec"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

// Exit code of `rofi` if the menu was cancelled (escape key).
const exitCodeCancelled = 1

func AddCmd(root *cobra.Command) {
	rofiCmd := &cobra.Command{
		Use:   "rofi",
		Short: "Rofi menu commands.",
	}

	addColorPickerCmd(rofiCmd)
	addEmojiCmd(rofiCmd)
	addLauncherCmd(rofiCmd)
	addNetworkCmd(rofiCmd)
	addPasswordCmd(rofiCmd)
	addPowerCmd(rofiCmd)
	addScreenrecordCmd(rofiCmd)
	addScreenshotCmd(rofiCmd)
	addSystemdCmd(rofiCmd)

	root.AddCommand(rofiCmd)
}

// runNotify returns a cobra run function which runs `f` and
// sends a warning notification `summary` if `f` fails.
func runNotify(summary string, f func() error) func(*cobra.Command, []string) error {
	return func(_cmd *cobra.Command, _args []string) error {
		err := f()
		if err != nil {
			notifyError(summary, err.Error())
		}

		return err
	}
}

// menu shows a `rofi` menu with `prompt` and the `entries` and returns the chosen entry.
// The `args` are added to the `rofi` arguments.
// Returns `ok == false` if the menu was cancelled.
func menu(prompt string, entries []string, args ...string) (choice string, ok bool, err error) {
	cancelled := false

	choice, err = exec.NewCommandCtx(".").
		WithStdin(strings.NewReader(strings.Join(entries, "\n"))).
		GetWithEC(
			func(e *exec.CmdError) error {
				if e != nil && e.ExitCode() == exitCodeCancelled {
					cancelled = true

					return nil
				}

				return e
			},
			append([]string{gexec.ExtCmdRofi, "-dmenu", "-p", prompt}, args...)...)
	if err != nil {
		return "", false, err
	}

	return choice, !cancelled, nil
}

// notify sends a desktop notification with `summary` and `body`.
// Errors are ignored.
func notify(summary string, body ...string) {
	_ = exec.NewCommandCtx(".").Check(append([]string{gexec.ExtCmdNotifySend, summary}, body...)...)
}

// notifyError sends a warning notification with `summary` and `body`
// over `notify-send` or `swaynag` if `notify-send` is not installed.
// Errors are ignored.
func notifyError(summary string, body ...string) {
	cmdx := exec.NewCommandCtx(".")

	if _, err := osexec.LookPath(gexec.ExtCmdNotifySend); err == nil {
		_ = cmdx.Check(append([]string{
			gexec.ExtCmdNotifySend, "--category", "warning", summary}, body...)...)

		return
	}

	_ = cmdx.Check(
		gexec.ExtCmdSwayNag,
		"-t",
		"warning",
		"-m",
		strings.Join(append([]string{summary}, body...), "\n"),
	)
}

// assertExe returns an error if one of the executables `exes` is not found in `PATH`.
func assertExe(exes ...string) error {
	for _, exe := range exes {
		if _, err := osexec.LookPath(exe); err != nil {
			return errors.New("executable '%s' not found, did you install it?", exe)
		}
	}

	return nil
}
