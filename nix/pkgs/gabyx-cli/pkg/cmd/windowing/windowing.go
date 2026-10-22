package windowingcmd

import (
	"bytes"
	"encoding/json"
	"os"

	"gabyx-cli/pkg/interactive"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

func AddCmd(root *cobra.Command) {
	windowingCmd := &cobra.Command{
		Use:   "windowing",
		Short: "Windowing (X11/sway) commands.",
	}

	windowingCmd.AddCommand(
		&cobra.Command{
			Use:   "print-keycode-table",
			Short: "Print the keycodes of the active keyboard.",
			Args:  cobra.NoArgs,
			RunE: func(_cmd *cobra.Command, _args []string) error {
				return interactive.Run(nil, "xmodmap", "-pke")
			},
		},
		&cobra.Command{
			Use:   "get-keycode",
			Short: "Get a keycode from a keypress.",
			Args:  cobra.NoArgs,
			RunE: func(_cmd *cobra.Command, _args []string) error {
				return interactive.Run(nil, "xev")
			},
		},
		&cobra.Command{
			Use:   "get-window-properties",
			Short: "Print the window tree of 'sway' in JSON format.",
			Args:  cobra.NoArgs,
			RunE: func(_cmd *cobra.Command, _args []string) error {
				return getWindowProperties()
			},
		},
		&cobra.Command{
			Use:   "get-input-properties [device-type]",
			Short: "Print the 'sway' input devices of type 'device-type' (default: 'touchpad').",
			Args:  cobra.MaximumNArgs(1),
			RunE: func(_cmd *cobra.Command, args []string) error {
				deviceType := "touchpad"
				if len(args) > 0 {
					deviceType = args[0]
				}

				return getInputProperties(deviceType)
			},
		},
	)

	root.AddCommand(windowingCmd)
}

func getWindowProperties() error {
	out, err := exec.NewCmdCtxBuilder().Quiet().Build().Get("swaymsg", "-t", "get_tree", "--raw")
	if err != nil {
		return err
	}

	return printJSON([]byte(out))
}

func getInputProperties(deviceType string) error {
	out, err := exec.NewCmdCtxBuilder().Quiet().Build().Get("swaymsg", "-t", "get_inputs", "--raw")
	if err != nil {
		return err
	}

	inputs, err := filterInputs([]byte(out), deviceType)
	if err != nil {
		return err
	}

	for _, in := range inputs {
		err = printJSON(in)
		if err != nil {
			return err
		}
	}

	return nil
}

// filterInputs returns all inputs in the JSON array `data` with type `deviceType`.
func filterInputs(data []byte, deviceType string) ([]json.RawMessage, error) {
	var inputs []json.RawMessage
	err := json.Unmarshal(data, &inputs)
	if err != nil {
		return nil, errors.AddContext(err, "could not parse inputs")
	}

	var res []json.RawMessage
	for _, in := range inputs {
		var t struct {
			Type string `json:"type"`
		}

		err = json.Unmarshal(in, &t)
		if err != nil {
			return nil, errors.AddContext(err, "could not parse input")
		}

		if t.Type == deviceType {
			res = append(res, in)
		}
	}

	return res, nil
}

func printJSON(data []byte) error {
	var buf bytes.Buffer
	err := json.Indent(&buf, data, "", "  ")
	if err != nil {
		return err
	}
	buf.WriteString("\n")

	_, err = buf.WriteTo(os.Stdout)

	return err
}
