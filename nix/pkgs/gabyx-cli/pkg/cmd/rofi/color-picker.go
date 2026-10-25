package roficmd

import (
	gexec "gabyx-cli/pkg/exec"

	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

const (
	colorPickOnScreen   = "On Screen Pick"
	colorPickColorwheel = "Colorwheel"
)

func addColorPickerCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "color-picker",
		Short: "Show the color picker menu (over 'hyprpicker' or 'gcolor3').",
		Args:  cobra.NoArgs,
		RunE:  runNotify("Color picking failed.", colorPicker),
	})
}

func colorPicker() error {
	err := assertExe(gexec.ExtCmdRofi)
	if err != nil {
		return err
	}

	choice, ok, err := menu("Color-Picking", []string{colorPickOnScreen, colorPickColorwheel})
	if err != nil || !ok {
		return err
	}

	switch choice {
	case colorPickOnScreen:
		err = assertExe(gexec.ExtCmdHyprpicker)
		if err != nil {
			return err
		}

		// Copies the color to the clipboard (`-a`).
		color, e := exec.NewCommandCtx(".").Get(gexec.ExtCmdHyprpicker, "-a", "--render-inactive")
		if e != nil {
			return e
		}

		if color != "" {
			notify("Color copied to your clipboard.", "Color '"+color+"'")
		}

		return nil
	case colorPickColorwheel:
		err = assertExe(gexec.ExtCmdGcolor3)
		if err != nil {
			return err
		}

		return exec.NewCommandCtx(".").Check(gexec.ExtCmdGcolor3)
	}

	return nil
}
