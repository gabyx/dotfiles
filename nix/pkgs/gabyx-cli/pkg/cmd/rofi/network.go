package roficmd

import (
	"context"
	"os"
	"path"

	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

func addNetworkCmd(parent *cobra.Command) {
	networkCmd := &cobra.Command{
		Use:   "network",
		Short: "Network menu commands.",
	}

	networkCmd.AddCommand(
		&cobra.Command{
			Use:   "wireless",
			Short: "Show the wireless network menu (over '~/.config/rofi/scripts/nmcli-rofi.sh').",
			Args:  cobra.NoArgs,
			RunE: func(_cmd *cobra.Command, _args []string) error {
				home, err := os.UserHomeDir()
				if err != nil {
					return err
				}

				return exec.NewCommandCtx(".").
					Check(path.Join(home, ".config/rofi/scripts/nmcli-rofi.sh"))
			},
		},
		&cobra.Command{
			Use:   "editor",
			Short: "Show the NetworkManager connection editor.",
			Args:  cobra.NoArgs,
			RunE: func(_cmd *cobra.Command, _args []string) error {
				return networkEditor()
			},
		},
	)

	parent.AddCommand(networkCmd)
}

// networkEditor runs `nm-connection-editor` and `nm-applet` in the background
// (for the password dialogs) until the editor exits.
func networkEditor() error {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	appletDone := make(chan struct{})
	go func() {
		// The error is ignored, cancelling kills `nm-applet`.
		_ = exec.NewCmdCtxBuilder().Context(ctx).Build().Check("nm-applet")
		close(appletDone)
	}()

	err := exec.NewCommandCtx(".").Check("nm-connection-editor")

	cancel()
	<-appletDone

	return err
}
