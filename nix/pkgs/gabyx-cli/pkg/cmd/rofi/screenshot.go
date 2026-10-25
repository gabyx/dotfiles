package roficmd

import (
	"bytes"
	"os"
	"path"
	"strings"
	"time"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

const (
	yes = "yes"
	no  = "no"

	// Date and time format of the screenshot and recording files.
	fileTimeFormat = "2006-01-02-150405"
)

// screenshotTarget is a menu entry and the corresponding `grimshot` target.
type screenshotTarget struct {
	label  string
	target string
}

func addScreenshotCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "screenshot",
		Short: "Show the screenshot menu (over 'grimshot' or 'grimblast').",
		Long: "Show the screenshot menu (over 'grimshot' or 'grimblast').\n" +
			"The screenshot is saved in '$SWAY_ROFI_SCREENSHOT_SAVEDIR' (default: '~/Pictures') " +
			"and copied to the clipboard.",
		Args: cobra.NoArgs,
		RunE: runNotify("Screenshot failed.", screenshot),
	})
}

// Adapted from https://github.com/gibbz00/sway-rofi-screenshot/blob/master/sway-rofi-screenshot.
func screenshot() error {
	grimshot := "grimshot"
	if os.Getenv("XDG_CURRENT_DESKTOP") == "Hyprland" {
		grimshot = "grimblast"
	}

	err := assertExe(grimshot, "rofi", "copyq", "gradia", "wl-copy")
	if err != nil {
		return err
	}

	cmdx := exec.NewCommandCtx(".")

	out, err := cmdx.GetCombined(grimshot, "check")
	if err != nil {
		return errors.New("'%s' has not all tools available, run '%s check':\n%s", grimshot, grimshot, out)
	}

	target, withCursor, edit, ok, err := screenshotMenus()
	if err != nil || !ok {
		return err
	}

	home, err := os.UserHomeDir()
	if err != nil {
		return err
	}

	file := screenshotFile(
		screenshotDir(os.Getenv("SWAY_ROFI_SCREENSHOT_SAVEDIR"), home),
		time.Now())

	err = os.MkdirAll(path.Dir(file), 0o755)
	if err != nil {
		return err
	}

	args := []string{grimshot}
	if withCursor {
		args = append(args, "--cursor")
	}
	args = append(args, "--notify", "save", target, file)

	err = cmdx.Check(args...)
	if err != nil {
		return err
	}

	if edit {
		err = cmdx.Check("gradia", file)
		if err != nil {
			return err
		}
	}

	err = copyImage(file)
	if err != nil {
		return err
	}

	_ = cmdx.Check("notify-send", "Screenshot",
		"File saved as <i>'"+file+"'</i> and copied to the clipboard.", "-i", file)

	return nil
}

// screenshotMenus shows the menus for the `grimshot` target, the cursor and the editing.
// Returns `ok == false` if a menu was cancelled or no target was chosen.
func screenshotMenus() (target string, withCursor bool, edit bool, ok bool, err error) {
	targets := []screenshotTarget{
		{label: "Manual Area", target: "area"},
		{label: "Active Window", target: "active"},
		{label: "Manual Window", target: "window"},
		{label: "Current Screen", target: "output"},
		{label: "All Screens", target: "screen"},
	}

	labels := make([]string, 0, len(targets))
	for _, t := range targets {
		labels = append(labels, t.label)
	}

	choice, ok, err := menu("Screenshot", labels)
	if err != nil || !ok {
		return "", false, false, false, err
	}

	for _, t := range targets {
		if t.label == choice {
			target = t.target
		}
	}

	if target == "" {
		return "", false, false, false, nil
	}

	cursorChoice, ok, err := menu("With Cursor?", []string{no, yes}, "-l", "2")
	if err != nil || !ok {
		return "", false, false, false, err
	}

	// A cancelled menu means no editing.
	editChoice, _, err := menu("Edit the shot?", []string{no, yes}, "-l", "2")
	if err != nil {
		return "", false, false, false, err
	}

	return target, cursorChoice == yes, editChoice == yes, true, nil
}

// copyImage copies the PNG image `file` to the Wayland clipboard and to `copyq`.
func copyImage(file string) error {
	content, err := os.ReadFile(file)
	if err != nil {
		return err
	}

	cmdx := exec.NewCommandCtx(".")

	// `copyq` has some trouble when copying big images,
	// therefore disable it and load the image manually.
	err = cmdx.Check("copyq", "disable")
	if err != nil {
		return err
	}
	defer func() { _ = cmdx.Check("copyq", "enable") }()

	err = cmdx.WithStdin(bytes.NewReader(content)).Check("wl-copy", "-t", "image/png")
	if err != nil {
		return err
	}

	return cmdx.WithStdin(bytes.NewReader(content)).Check("copyq", "write", "image/png", "-")
}

// screenshotDir returns the screenshot directory `dir` with a leading `~` replaced by `home`.
// Returns `~/Pictures` if `dir` is empty.
func screenshotDir(dir string, home string) string {
	if dir == "" {
		return path.Join(home, "Pictures")
	}

	if rest, found := strings.CutPrefix(dir, "~"); found {
		return home + rest
	}

	return dir
}

// screenshotFile returns the screenshot file in `dir` for time `t`.
func screenshotFile(dir string, t time.Time) string {
	return path.Join(dir, t.Format(fileTimeFormat)+"-screenshot.png")
}
