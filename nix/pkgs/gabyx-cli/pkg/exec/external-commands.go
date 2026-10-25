// Package exec lists all external executables which `gabyx` runs.
// The Nix package (`default.nix`) adds some of them to `PATH`,
// all others must be installed on the system.
package exec

// Sorted by the modules in which they are needed.
const (
	// Needed in: browser.
	ExtCmdZen = "zen"

	// Needed in: container.
	ExtCmdDocker = "docker"
	ExtCmdPodman = "podman"

	// Needed in: git, fileregexreplace (run over quitsh `git.NewCtx`).
	ExtCmdGit = "git"

	// Needed in: music.
	ExtCmdChown = "chown"
	ExtCmdLsblk = "lsblk"

	// Needed in: nixos.
	ExtCmdJournalctl = "journalctl"
	ExtCmdLsmod      = "lsmod"

	// Needed in: pdf.
	ExtCmdGs = "gs"

	// Needed in: rofi.
	ExtCmdFfmpeg             = "ffmpeg"
	ExtCmdGcolor3            = "gcolor3"
	ExtCmdGradia             = "gradia"
	ExtCmdGrimblast          = "grimblast"
	ExtCmdGrimshot           = "grimshot"
	ExtCmdHyprpicker         = "hyprpicker"
	ExtCmdNmApplet           = "nm-applet"
	ExtCmdNmConnectionEditor = "nm-connection-editor"
	ExtCmdRofi               = "rofi"
	ExtCmdRofiPowerMenu      = "rofi-power-menu"
	ExtCmdRofiRbw            = "rofi-rbw"
	ExtCmdRofiSystemd        = "rofi-systemd"
	ExtCmdRofimoji           = "rofimoji"
	ExtCmdSlurp              = "slurp"
	ExtCmdSwayNag            = "swaynag"
	ExtCmdTimeout            = "timeout"
	ExtCmdWfRecorder         = "wf-recorder"
	ExtCmdWlCopy             = "wl-copy"

	// Needed in: rofi, sway, waybar, windowing.
	ExtCmdNotifySend = "notify-send"
	// Needed in: rofi, windowing.
	ExtCmdCopyq = "copyq"

	// Needed in: secret.
	ExtCmdAge   = "age"
	ExtCmdBw    = "bw"
	ExtCmdYkman = "ykman"

	// Needed in: sudo (all commands run with root rights).
	ExtCmdSudo = "sudo"

	// Needed in: sway, windowing.
	ExtCmdSwaymsg = "swaymsg"

	// Needed in: term.
	ExtCmdWezterm = "wezterm"

	// Needed in: tmux.
	ExtCmdTmux      = "tmux"
	ExtCmdTmuxifier = "tmuxifier"

	// Needed in: vpn.
	ExtCmdExpect    = "expect"
	ExtCmdProtonvpn = "protonvpn"

	// Needed in: vpn, waybar.
	ExtCmdNmcli = "nmcli"

	// Needed in: waybar.
	ExtCmdKhal      = "khal"
	ExtCmdLast      = "last"
	ExtCmdPlayerctl = "playerctl"
	ExtCmdSystemctl = "systemctl"
	ExtCmdXdgOpen   = "xdg-open"

	ExtCmdBrightnessctl      = "brightnessctl"
	ExtCmdGammastepIndicator = "gammastep-indicator"
	ExtCmdHyprctl            = "hyprctl"
	ExtCmdNiri               = "niri"
	ExtCmdPavucontrol        = "pavucontrol"
	ExtCmdQalculateGtk       = "qalculate-gtk"
	ExtCmdRofiBluetooth      = "rofi-bluetooth"
	ExtCmdSwaync             = "swaync"
	ExtCmdSwayncClient       = "swaync-client"
	ExtCmdWayDisplays        = "way-displays"
	ExtCmdXev                = "xev"
	ExtCmdXmodmap            = "xmodmap"

	// Needed in: zfs (used by music, filesystem).
	ExtCmdZfs = "zfs"
	// Needed in: zfs (used by music, filesystem).
	ExtCmdZpool = "zpool"
)
