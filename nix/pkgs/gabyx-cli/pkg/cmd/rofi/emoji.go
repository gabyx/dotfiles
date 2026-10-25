package roficmd

import (
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

func addEmojiCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "emoji",
		Short: "Show the emoji menu (types the emoji, 'Ctrl+y' copies it).",
		Args:  cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			return exec.NewCommandCtx(".").
				Check("rofimoji",
					"--clipboarder", "wl-copy",
					"--action", "type", "copy",
					"--keybinding-copy", "Ctrl-y")
		},
	})
}
