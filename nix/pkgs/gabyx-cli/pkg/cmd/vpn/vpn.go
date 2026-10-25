package vpncmd

import (
	_ "embed"
	"os"
	"path"
	"strings"

	gexec "gabyx-cli/pkg/exec"
	"gabyx-cli/pkg/interactive"
	"gabyx-cli/pkg/prompt"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/spf13/cobra"
)

//go:embed connect-ethz.tcl
var connectETHZScript string

func AddCmd(root *cobra.Command) {
	vpnCmd := &cobra.Command{
		Use:   "vpn",
		Short: "VPN commands.",
	}

	vpnCmd.AddCommand(
		&cobra.Command{
			Use:   "protonvpn-connect <country>...",
			Short: "Connect the Proton VPN connection.",
			Args:  cobra.MinimumNArgs(1),
			RunE: func(_cmd *cobra.Command, args []string) error {
				return interactive.Run(nil,
					append([]string{gexec.ExtCmdProtonvpn, "connect", "--country"}, args...)...)
			},
		},
		&cobra.Command{
			Use:   "protonvpn-disconnect",
			Short: "Disconnect the Proton VPN connection.",
			Args:  cobra.NoArgs,
			RunE: func(_cmd *cobra.Command, _args []string) error {
				return interactive.Run(nil, gexec.ExtCmdProtonvpn, "disconnect")
			},
		},
		&cobra.Command{
			Use:   "connect [name]",
			Short: "Connect the NetworkManager VPN connection 'name' (default: 'eth-zurich-vpn').",
			Args:  cobra.MaximumNArgs(1),
			RunE: func(_cmd *cobra.Command, args []string) error {
				name := "eth-zurich-vpn"
				if len(args) > 0 {
					name = args[0]
				}

				return interactive.Run(nil, gexec.ExtCmdNmcli, "connection", "up", name, "--ask")
			},
		},
		&cobra.Command{
			Use:   "connect-auto",
			Short: "Connect the ETH Zurich VPN with credentials from '~/.config/vpn/eth-zurich-credentials'.",
			Args:  cobra.NoArgs,
			RunE: func(_cmd *cobra.Command, _args []string) error {
				return connectAuto()
			},
		},
	)

	root.AddCommand(vpnCmd)
}

func connectAuto() error {
	exe, err := os.Executable()
	if err != nil {
		return err
	}

	creds, err := readETHZCredentials()
	if err != nil {
		return err
	}

	f, err := os.CreateTemp("", "gabyx-connect-ethz-*.tcl")
	if err != nil {
		return err
	}
	defer func() { _ = os.Remove(f.Name()) }()

	_, err = f.WriteString(connectETHZScript)
	_ = f.Close()
	if err != nil {
		return err
	}

	password, err := prompt.Get("Enter VPN password: ", true)
	if err != nil {
		return err
	}

	otp, err := prompt.Get("Enter One Time Password: ", false)
	if err != nil {
		return err
	}

	return interactive.Run(
		[]string{
			"GABYX_EXE=" + exe,
			"GABYX_VPN_NETWORK=" + creds.network,
			"GABYX_VPN_GROUP=" + creds.group,
			"GABYX_VPN_USERNAME=" + creds.username,
			"GABYX_VPN_PASSWORD=" + password,
			"GABYX_VPN_OTP=" + otp,
		},
		gexec.ExtCmdExpect, "-f", f.Name())
}

type ethzCredentials struct {
	network  string
	group    string
	username string
}

// readETHZCredentials reads '~/.config/vpn/eth-zurich-credentials'
// which contains the lines: network, group, username.
func readETHZCredentials() (c ethzCredentials, err error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return c, err
	}

	file := path.Join(home, ".config", "vpn", "eth-zurich-credentials")
	content, err := os.ReadFile(file)
	if err != nil {
		return c, errors.AddContext(err, "could not read credentials file '%s'", file)
	}

	lines := strings.Split(strings.TrimSpace(string(content)), "\n")
	if len(lines) < 3 { //nolint:mnd // Number of lines in the file.
		return c, errors.New("credentials file '%s' needs 3 lines: network, group, username", file)
	}

	c.network = strings.TrimSpace(lines[0])
	c.group = strings.TrimSpace(lines[1])
	c.username = strings.TrimSpace(lines[2])

	return c, nil
}
