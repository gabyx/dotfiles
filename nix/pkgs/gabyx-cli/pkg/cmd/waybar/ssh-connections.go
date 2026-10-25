package waybarcmd

import (
	"strconv"
	"strings"

	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

func addSSHConnectionsCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "ssh-connections",
		Short: "Print the number of logged in SSH sessions (pseudo terminals) for Waybar.",
		Args:  cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			return sshConnections()
		},
	})
}

func sshConnections() error {
	lines, err := exec.NewCommandCtx(".").GetSplit("last", "-a")
	if err != nil {
		return err
	}

	connections := countSSHConnections(lines)

	o := output{
		Text:       "",
		Alt:        valueNone,
		Tooltip:    "connections: " + strconv.Itoa(connections),
		Class:      "normal",
		Percentage: 0,
	}

	if connections != 0 {
		o.Alt = "some"
		o.Class = "warning"
		o.Percentage = connections
	}

	return o.print()
}

// countSSHConnections counts the lines of `last -a` with sessions
// on a pseudo terminal which are still logged in.
func countSSHConnections(lines []string) (count int) {
	for _, l := range lines {
		if strings.Contains(strings.ToLower(l), "still logged in") && strings.Contains(l, "pts/") {
			count++
		}
	}

	return count
}
