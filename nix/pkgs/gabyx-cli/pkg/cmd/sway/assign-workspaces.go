package swaycmd

import (
	"encoding/json"
	"fmt"
	"os"
	"path"
	"regexp"
	"slices"
	"strings"

	gexec "gabyx-cli/pkg/exec"

	"deedles.dev/xiter"
	qStrs "github.com/gabyx/quitsh/pkg/common/strings"
	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

const (
	notifyTitle = "Assign workspaces to outputs."

	// Outputs used if no display of the `sway` config is connected.
	externalPrimary   = "DP-1"
	externalSecondary = "DP-2"
)

type assignWorkspacesArgs struct {
	swap bool
}

// swayOutput is an output of `swaymsg -t get_outputs`.
type swayOutput struct {
	Name   string `json:"name"`
	Make   string `json:"make"`
	Model  string `json:"model"`
	Serial string `json:"serial"`
}

// swayWorkspace is a workspace of `swaymsg -t get_workspaces`.
type swayWorkspace struct {
	Name    string `json:"name"`
	Focused bool   `json:"focused"`
}

type displays struct {
	primary   string
	secondary string
}

// report collects the messages for the notification.
type report struct {
	lines []string
}

func addAssignWorkspacesCmd(parent *cobra.Command) {
	var args assignWorkspacesArgs

	cmd := &cobra.Command{
		Use:   "assign-workspaces-to-outputs",
		Short: "Move the workspaces to the primary and secondary display and send a notification.",
		Long: `
    Detects the primary and secondary display: first the 'Home' and then the 'Work'
    displays ('set $primaryDisp<Type> ...', 'set $secondaryDisp<Type> ...' in
    '~/.config/sway/config'), otherwise the outputs 'DP-1' and 'DP-2'.
    Moves all workspaces assigned to '$primaryDisp' or '$secondaryDisp' in
    '~/.config/sway/config-workspaces' to that display.
    Useful when the workspaces get messed up, e.g. after a display change
    (run by 'way-displays').
`,
		Args: cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			r := report{lines: nil}
			err := assignWorkspaces(&r, args.swap)

			e := exec.NewCommandCtx(".").
				Check(append([]string{gexec.ExtCmdNotifySend}, notifyArgs(r.String(), err)...)...)

			return errors.Combine(err, e)
		},
	}

	cmd.Flags().
		BoolVar(&args.swap, "swap", false, "Swap the primary and secondary display.")

	parent.AddCommand(cmd)
}

func (r *report) addf(format string, args ...any) {
	msg := fmt.Sprintf(format, args...)
	log.Info(msg)
	r.lines = append(r.lines, msg)
}

func (r *report) String() string {
	return strings.Join(r.lines, "\n")
}

func assignWorkspaces(r *report, swap bool) error {
	home, err := os.UserHomeDir()
	if err != nil {
		return err
	}

	config, err := os.ReadFile(path.Join(home, ".config", "sway", "config"))
	if err != nil {
		return errors.AddContext(err, "cannot assign workspaces")
	}

	configWorkspaces, err := os.ReadFile(path.Join(home, ".config", "sway", "config-workspaces"))
	if err != nil {
		return errors.AddContext(err, "cannot assign workspaces")
	}

	outputs, err := getOutputs()
	if err != nil {
		return err
	}

	disp, err := detectDisplays(r, string(config), outputs)
	if err != nil {
		return err
	}

	if swap {
		disp.primary, disp.secondary = disp.secondary, disp.primary
	}

	r.addf("Setting primary display to: '%s'.", disp.primary)
	r.addf("Setting secondary display to: '%s'.", disp.secondary)

	lastFocused, err := focusedWorkspace()
	if err != nil {
		return err
	}

	swaymsg := func(command string) error {
		return exec.NewCommandCtx(".").Check(gexec.ExtCmdSwaymsg, "-q", command)
	}

	// Configure all displays.
	for _, c := range []string{
		"set $primaryDisp " + disp.primary,
		"set $secondaryDisp '" + disp.secondary + "'",
		stripComments(string(configWorkspaces)),
	} {
		err = swaymsg(c)
		if err != nil {
			return err
		}
	}

	// Move existing workspaces to the correct display.
	primary, secondary := workspaceAssignments(string(configWorkspaces))
	for _, ws := range primary {
		r.addf("Move workspace '%s' to primary display.", ws)

		err = swaymsg("workspace " + ws + "; move workspace to output '" + disp.primary + "'")
		if err != nil {
			return err
		}
	}

	for _, ws := range secondary {
		r.addf("Move workspace '%s' to secondary display.", ws)

		err = swaymsg("workspace " + ws + "; move workspace to output '" + disp.secondary + "'")
		if err != nil {
			return err
		}
	}

	return swaymsg("workspace '" + lastFocused + "'")
}

func getOutputs() (outputs []swayOutput, err error) {
	out, err := exec.NewCommandCtx(".").Get(gexec.ExtCmdSwaymsg, "-t", "get_outputs", "--raw")
	if err != nil {
		return nil, err
	}

	err = json.Unmarshal([]byte(out), &outputs)
	if err != nil {
		return nil, errors.AddContext(err, "could not parse sway outputs")
	}

	return outputs, nil
}

func focusedWorkspace() (string, error) {
	out, err := exec.NewCommandCtx(".").Get(gexec.ExtCmdSwaymsg, "-t", "get_workspaces", "--raw")
	if err != nil {
		return "", err
	}

	var workspaces []swayWorkspace

	err = json.Unmarshal([]byte(out), &workspaces)
	if err != nil {
		return "", errors.AddContext(err, "could not parse sway workspaces")
	}

	for _, ws := range workspaces {
		if ws.Focused {
			return ws.Name, nil
		}
	}

	return "", errors.New("no focused workspace found")
}

// detectDisplays returns the primary and secondary display:
// the `Home` or `Work` displays defined in the sway config `config`
// or otherwise the outputs `DP-1` and `DP-2`.
// If no secondary display is found, the primary is taken.
func detectDisplays(r *report, config string, outputs []swayOutput) (displays, error) {
	disp := displays{primary: "", secondary: ""}

	for _, typ := range []string{"Home", "Work"} {
		r.addf("Detecting monitors for type '%s'.", typ)

		disp.primary = definedDisplay(r, config, outputs, "primary", typ)
		if disp.primary == "" {
			r.addf("No primary monitor for '%s' found.", typ)

			continue
		}

		disp.secondary = definedDisplay(r, config, outputs, "secondary", typ)
		r.addf("Detected %s monitors.", typ)

		break
	}

	if disp.primary == "" {
		r.addf("Detecting monitors for type 'External'.")

		if hasOutput(outputs, externalPrimary) {
			disp.primary = externalPrimary
		}

		if hasOutput(outputs, externalSecondary) {
			disp.secondary = externalSecondary
		}
	}

	if disp.primary == "" {
		return disp, errors.New("detected no monitors to assign workspaces")
	}

	if disp.secondary == "" {
		r.addf("Secondary monitor not detected, taking primary.")
		disp.secondary = disp.primary
	}

	return disp, nil
}

// definedDisplay returns the display `set $<which>Disp<typ> '<display>'` in the sway
// config `config` if it is connected, otherwise `""`.
func definedDisplay(
	r *report,
	config string,
	outputs []swayOutput,
	which string,
	typ string,
) string {
	re := regexp.MustCompile(`(?m)^set \$` + which + `Disp` + typ + ` '(.*)'`)

	m := re.FindStringSubmatch(config)
	if m == nil {
		r.addf("- Display %s '%s' not defined in 'sway/config'.", which, typ)

		return ""
	}

	if !hasOutput(outputs, m[1]) {
		r.addf("- Display %s '%s' not found in outputs.", which, m[1])

		return ""
	}

	return m[1]
}

// hasOutput returns `true` if an output has the name or
// the identifier `<make> <model> <serial>` equal to `display`.
func hasOutput(outputs []swayOutput, display string) bool {
	for _, o := range outputs {
		if o.Name == display || o.Make+" "+o.Model+" "+o.Serial == display {
			return true
		}
	}

	return false
}

// workspaceAssignments returns the workspaces assigned with
// `workspace <ws> output $primaryDisp` and `workspace <ws> output $secondaryDisp`
// in `configWorkspaces`.
func workspaceAssignments(configWorkspaces string) (primary []string, secondary []string) {
	re := regexp.MustCompile(`(?m)^\s*workspace\s+(\S+)\s+output\s+\$(primary|secondary)Disp\s*$`)

	for _, m := range re.FindAllStringSubmatch(configWorkspaces, -1) {
		if m[2] == "primary" {
			primary = append(primary, m[1])
		} else {
			secondary = append(secondary, m[1])
		}
	}

	return primary, secondary
}

// stripComments empties all comment lines in `content`.
func stripComments(content string) string {
	return xiter.StringJoin(
		xiter.Filter(
			slices.Values(qStrs.SplitLines(content)), func(l string) bool {
				return !strings.HasPrefix(l, "#")
			}), "\n")
}

// notifyArgs returns the `notify-send` arguments for the report `msg`.
func notifyArgs(msg string, err error) []string {
	if err == nil {
		return []string{notifyTitle, "Workspaces moved:\n" + msg}
	}

	return []string{
		"-u",
		"normal",
		notifyTitle,
		"Workspaces not moved:\n" + msg + "\n" + err.Error(),
	}
}
