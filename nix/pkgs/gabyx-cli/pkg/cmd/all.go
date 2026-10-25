package cmd

import (
	browserCmd "gabyx-cli/pkg/cmd/browser"
	containerCmd "gabyx-cli/pkg/cmd/container"
	fileRegexReplaceCmd "gabyx-cli/pkg/cmd/fileregexreplace"
	filesystemCmd "gabyx-cli/pkg/cmd/filesystem"
	gitCmd "gabyx-cli/pkg/cmd/git"
	musicCmd "gabyx-cli/pkg/cmd/music"
	nixosCmd "gabyx-cli/pkg/cmd/nixos"
	pdfCmd "gabyx-cli/pkg/cmd/pdf"
	secretCmd "gabyx-cli/pkg/cmd/secret"
	tmuxCmd "gabyx-cli/pkg/cmd/tmux"
	vpnCmd "gabyx-cli/pkg/cmd/vpn"
	windowingCmd "gabyx-cli/pkg/cmd/windowing"

	"github.com/gabyx/quitsh/pkg/cli"
)

func AddCommands(cl cli.ICLI) {
	root := cl.RootCmd()

	browserCmd.AddCmd(root)
	containerCmd.AddCmd(root)
	fileRegexReplaceCmd.AddCmd(root)
	filesystemCmd.AddCmd(root)
	gitCmd.AddCmd(root)
	musicCmd.AddCmd(root)
	nixosCmd.AddCmd(root)
	pdfCmd.AddCmd(root)
	secretCmd.AddCmd(root)
	tmuxCmd.AddCmd(root)
	vpnCmd.AddCmd(root)
	windowingCmd.AddCmd(root)
}
