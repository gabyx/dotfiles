package waybarcmd

import (
	"strings"

	gexec "gabyx-cli/pkg/exec"

	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

// Separator of the fields in the `playerctl --format` output.
// The ASCII unit separator is not whitespace and not trimmed with the output.
const playerctlSep = "\x1f"

func addMediaPlayerCmd(parent *cobra.Command) {
	mediaCmd := &cobra.Command{
		Use:   "media-player",
		Short: "Print the state, artist and title of the media player (over 'playerctl') for Waybar.",
		Args:  cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			return mediaPlayer()
		},
	}

	mediaCmd.AddCommand(&cobra.Command{
		Use:   "toggle",
		Short: "Toggle between play and pause of the media player.",
		Args:  cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			return exec.NewCommandCtx(".").Check(gexec.ExtCmdPlayerctl, "play-pause")
		},
	})

	parent.AddCommand(mediaCmd)
}

// mediaPlayer prints the state (`alt` and `class`: `playing`, `paused` or `none`)
// and `<artist> ● <title>` as tooltip.
func mediaPlayer() error {
	o := output{Text: "", Alt: valueNone, Tooltip: "", Class: valueNone, Percentage: 0}

	// Fails if no player is running.
	out, err := exec.NewCommandCtx(".").Get(gexec.ExtCmdPlayerctl, "metadata", "--format",
		strings.Join([]string{"{{status}}", "{{artist}}", "{{title}}"}, playerctlSep))
	if err != nil {
		return o.print()
	}

	status, artist, title, ok := parsePlayerctl(out)
	if !ok || (status != "playing" && status != "paused") {
		return o.print()
	}

	o.Alt = strings.ToLower(status)
	o.Class = o.Alt
	o.Tooltip = artist + " " + Bullet + " " + title

	return o.print()
}

// parsePlayerctl splits the `playerctl --format` output `out` into
// status, artist and title.
func parsePlayerctl(out string) (status, artist, title string, ok bool) {
	f := strings.Split(out, playerctlSep)
	if len(f) != 3 { //nolint:mnd // Number of fields.
		return "", "", "", false
	}

	return strings.ToLower(f[0]), f[1], f[2], true
}
