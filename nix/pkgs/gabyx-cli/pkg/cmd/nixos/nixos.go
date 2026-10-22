package nixoscmd

import (
	"gabyx-cli/pkg/interactive"

	"github.com/spf13/cobra"
)

func AddCmd(root *cobra.Command) {
	nixosCmd := &cobra.Command{
		Use:   "nixos",
		Short: "NixOS commands.",
	}

	nixosCmd.AddCommand(
		&cobra.Command{
			Use:   "last-boot-log",
			Short: "Show the log of the last boot.",
			Args:  cobra.NoArgs,
			RunE: func(_cmd *cobra.Command, _args []string) error {
				return interactive.Run(nil, "journalctl", "-b", "-1", "-e")
			},
		},
		&cobra.Command{
			Use:   "systemd-log",
			Short: "Show the log of all user systemd services.",
			Args:  cobra.NoArgs,
			RunE: func(_cmd *cobra.Command, _args []string) error {
				return interactive.Run(nil, "journalctl", "--user", "-e")
			},
		},
		&cobra.Command{
			Use:   "systemd-log-for <service>",
			Short: "Show the log of the systemd service 'service' (user log: 'user@1000').",
			Args:  cobra.ExactArgs(1),
			RunE: func(_cmd *cobra.Command, args []string) error {
				return interactive.Run(nil, "journalctl", "-u", args[0]+".service", "-e")
			},
		},
		&cobra.Command{
			Use:   "hm-log",
			Short: "Show the log of the home-manager systemd service.",
			Args:  cobra.NoArgs,
			RunE: func(_cmd *cobra.Command, _args []string) error {
				return interactive.Run(nil, "journalctl", "-u", "home-manager-nixos.service", "-e")
			},
		},
		&cobra.Command{
			Use:   "kernel-modules",
			Short: "List all loaded kernel modules.",
			Args:  cobra.NoArgs,
			RunE: func(_cmd *cobra.Command, _args []string) error {
				return interactive.Run(nil, "lsmod")
			},
		},
	)

	root.AddCommand(nixosCmd)
}
