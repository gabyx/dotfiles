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
	rofiCmd "gabyx-cli/pkg/cmd/rofi"
	secretCmd "gabyx-cli/pkg/cmd/secret"
	swayCmd "gabyx-cli/pkg/cmd/sway"
	termCmd "gabyx-cli/pkg/cmd/term"
	tmuxCmd "gabyx-cli/pkg/cmd/tmux"
	vpnCmd "gabyx-cli/pkg/cmd/vpn"
	waybarCmd "gabyx-cli/pkg/cmd/waybar"
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
	rofiCmd.AddCmd(root)
	secretCmd.AddCmd(root)
	swayCmd.AddCmd(root)
	termCmd.AddCmd(root)
	tmuxCmd.AddCmd(root)
	vpnCmd.AddCmd(root)
	waybarCmd.AddCmd(root)
	windowingCmd.AddCmd(root)
}
