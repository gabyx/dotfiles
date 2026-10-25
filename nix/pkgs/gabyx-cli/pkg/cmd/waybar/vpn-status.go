package waybarcmd

import (
	"net"
	"slices"
	"strings"

	"deedles.dev/xiter"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

// Interface of NordVPN (WireGuard).
const nordVPNInterface = "wgnord"

func addVPNStatusCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "vpn-status",
		Short: "Print the VPN status (NetworkManager or NordVPN) for Waybar.",
		Args:  cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			name := activeVPN()

			if name == "" {
				o := output{
					Text:       "",
					Alt:        "",
					Tooltip:    "VPN Disconnected",
					Class:      "disconnected",
					Percentage: 0,
				}

				return o.print()
			}

			o := output{
				Text:       "",
				Alt:        "",
				Tooltip:    "VPN:\n" + name,
				Class:      "connected",
				Percentage: 100,
			} //nolint:mnd

			return o.print()
		},
	})
}

// activeVPN returns the name of the active VPN or `""` if none is active.
func activeVPN() string {
	message := ""

	// Check VPN over NetworkManager.
	lines, err := exec.NewCommandCtx(".").
		GetSplit("nmcli", "--fields", "NAME,TYPE", "connection", "show", "--active")
	if err != nil {
		log.ErrorE(err, "could not get connections")
	} else {
		message += xiter.StringJoin(
			xiter.Map(
				xiter.Filter(
					xiter.Map(
						slices.Values(lines),
						func(l string) string { return strings.TrimSpace(l) },
					),
					func(s string) bool {
						return strings.HasSuffix(s, "wireguard")
					},
				),
				func(s string) string { return Bullet + " " + s }), "\n")
	}

	// Check if NordVPN has an IPv4 address.
	if hasIPv4(nordVPNInterface) {
		message += "\n" + Bullet + " " + nordVPNInterface
	}

	return message
}

// hasIPv4 returns `true` if the network interface `name` exists and has an IPv4 address.
func hasIPv4(name string) bool {
	iface, err := net.InterfaceByName(name)
	if err != nil {
		return false
	}

	addrs, err := iface.Addrs()
	if err != nil {
		return false
	}

	for _, a := range addrs {
		if ip, ok := a.(*net.IPNet); ok && ip.IP.To4() != nil {
			return true
		}
	}

	return false
}
