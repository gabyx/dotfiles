package waybarcmd

import (
	"encoding/json"
	"os"

	"github.com/spf13/cobra"
)

// The `alt` or `class` value for "nothing to show".
const valueNone = "none"

// output is the JSON output of a Waybar custom module with `return-type = "json"`.
type output struct {
	Text       string `json:"text"`
	Alt        string `json:"alt,omitempty"`
	Tooltip    string `json:"tooltip,omitempty"`
	Class      string `json:"class,omitempty"`
	Percentage int    `json:"percentage"`
}

func AddCmd(root *cobra.Command) {
	waybarCmd := &cobra.Command{
		Use:   "waybar",
		Short: "Waybar custom module commands.",
	}

	addBackupCmd(waybarCmd)
	addMediaPlayerCmd(waybarCmd)
	addNextMeetingCmd(waybarCmd)
	addSSHConnectionsCmd(waybarCmd)
	addTooltipCmd(waybarCmd)
	addVPNStatusCmd(waybarCmd)

	root.AddCommand(waybarCmd)
}

// print writes `o` as one JSON line to stdout.
func (o *output) print() error {
	enc := json.NewEncoder(os.Stdout)
	enc.SetEscapeHTML(false)

	return enc.Encode(o)
}
