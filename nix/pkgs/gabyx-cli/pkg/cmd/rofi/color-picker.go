package roficmd

import (
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
	err := assertExe("rofi")
	if err != nil {
		return err
	}

	choice, ok, err := menu("Color-Picking", []string{colorPickOnScreen, colorPickColorwheel})
	if err != nil || !ok {
		return err
	}

	switch choice {
	case colorPickOnScreen:
		err = assertExe("hyprpicker")
		if err != nil {
			return err
		}

		// Copies the color to the clipboard (`-a`).
		color, e := exec.NewCommandCtx(".").Get("hyprpicker", "-a", "--render-inactive")
		if e != nil {
			return e
		}

		if color != "" {
			notify("Color copied to your clipboard.", "Color '"+color+"'")
		}

		return nil
	case colorPickColorwheel:
		err = assertExe("gcolor3")
		if err != nil {
			return err
		}

		return exec.NewCommandCtx(".").Check("gcolor3")
	}

	return nil
}
