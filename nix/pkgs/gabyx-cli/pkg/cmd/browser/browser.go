package browsercmd

import (
	"context"
	"os"
	"os/exec"
	"path"
	"syscall"

	gexec "gabyx-cli/pkg/exec"

	fs "github.com/gabyx/quitsh/pkg/filesystem"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

func AddCmd(root *cobra.Command) {
	browserCmd := &cobra.Command{
		Use:   "browser",
		Short: "Browser commands.",
	}

	startNewCmd := &cobra.Command{
		Use:   "start-new",
		Short: "Start a detached 'zen' browser with the separate profile 'zen/VPN'.",
		Args:  cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			return startNew()
		},
	}

	browserCmd.AddCommand(startNewCmd)
	root.AddCommand(browserCmd)
}

func startNew() error {
	configDir := os.Getenv("XDG_CONFIG_DIR")
	if configDir == "" {
		home, err := os.UserHomeDir()
		if err != nil {
			return err
		}
		configDir = path.Join(home, ".config")
	}

	dir := path.Join(configDir, "zen", "VPN")
	err := os.MkdirAll(dir, fs.DefaultPermissionsDir) //nolint:gosec // Path from the user config dir.
	if err != nil {
		return err
	}

	// Not canceled with the CLI context, since the browser is detached.
	//nolint:gosec // Path from config dir.
	cmd := exec.CommandContext(context.Background(), gexec.ExtCmdZen, "--profile", dir)
	cmd.SysProcAttr = &syscall.SysProcAttr{Setsid: true} //nolint:exhaustruct // Only a new session.

	log.Info("Starting browser.", "profile", dir)
	err = cmd.Start()
	if err != nil {
		return err
	}

	return cmd.Process.Release()
}
