package waybarcmd

import (
	"encoding/json"
	"os"
	"path"
	"strconv"
	"strings"

	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

const (
	// Directory with the `<name>/status` and `<name>/snapshots` files
	// written by the backup services (`nix/nixos/backup.nix`).
	backupReportDir = "/var/lib/backups"

	// Status lines are broken after this number of characters.
	backupStatusWidth = 80
)

// The overall backup state. A higher state overrides a lower one.
const (
	backupNone backupState = iota
	backupSuccess
	backupFailure
	backupRunning
)

type backupState int

func addBackupCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "backup",
		Short: "Print the state of the restic backup services for Waybar.",
		Args:  cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			return backupStatus(backupReportDir)
		},
	})
}

func backupNames() []string {
	return []string{"nixos-desktop", "nixos-tuxedo", "data-personal"}
}

func (s backupState) String() string {
	switch s {
	case backupSuccess:
		return "success"
	case backupFailure:
		return "failure"
	case backupRunning:
		return "running"
	case backupNone:
	}

	return valueNone
}

func backupStatus(reportDir string) error {
	state := backupNone
	var lines []string

	for _, name := range backupNames() {
		unit := "restic-backups-" + name + ".service"
		log.Debug("Checking unit.", "unit", unit)

		if !unitExists(unit) {
			log.Debug("Unit does not exist.", "unit", unit)

			continue
		}

		s, line := backupUnitStatus(reportDir, name, unitRunning(unit))
		state = max(state, s)
		lines = append(lines, line, snapshotCount(reportDir, name), "")
	}

	tooltip := strings.Builder{}
	tooltip.WriteString("Backups:\n")
	for _, l := range lines {
		tooltip.WriteString(l + "\n")
	}

	o := output{
		Text:       "",
		Alt:        state.String(),
		Tooltip:    tooltip.String(),
		Class:      state.String(),
		Percentage: 0,
	}

	return o.print()
}

// backupUnitStatus returns the state and the status line of the backup `name`.
func backupUnitStatus(reportDir string, name string, running bool) (backupState, string) {
	if running {
		return backupRunning, "· 🏃🏽‍♀️ '" + name + "' ..."
	}

	status := lastStatus(reportDir, name)

	switch {
	case strings.Contains(status, "success"):
		return backupSuccess, "· " + status
	case strings.Contains(status, "failure"):
		return backupFailure, "· " + status
	default:
		log.Debug("Could not determine status.", "backup", name)

		return backupFailure, "· ⁉️ '" + name + "'"
	}
}

// unitExists returns `true` if the systemd unit `unit` is loaded.
func unitExists(unit string) bool {
	state, err := exec.NewCommandCtx(".").
		Get("systemctl", "show", "-p", "LoadState", "--value", unit)

	return err == nil && state == "loaded"
}

// unitRunning returns `true` if the systemd unit `unit` is
// neither inactive nor failed.
func unitRunning(unit string) bool {
	// `systemctl is-active` exits non-zero if the unit is not active.
	state, _ := exec.NewCommandCtx(".").
		GetWithEC(func(*exec.CmdError) error { return nil }, "systemctl", "is-active", unit)

	return !strings.Contains(state, "inactive") && !strings.Contains(state, "failed")
}

// lastStatus returns the last line of the status file of backup `name`
// broken into lines of `backupStatusWidth` characters.
func lastStatus(reportDir string, name string) string {
	content, err := os.ReadFile(path.Join(reportDir, name, "status"))
	if err != nil {
		return ""
	}

	lines := strings.Split(strings.TrimRight(string(content), "\n"), "\n")

	return breakLine(lines[len(lines)-1], backupStatusWidth)
}

// breakLine appends `\n  ` after every `width` characters of `s`.
func breakLine(s string, width int) string {
	runes := []rune(s)
	b := strings.Builder{}

	for len(runes) >= width {
		b.WriteString(string(runes[:width]) + "\n  ")
		runes = runes[width:]
	}
	b.WriteString(string(runes))

	return b.String()
}

// snapshotCount returns the line with the number of snapshots of backup `name`.
// The snapshots file is the output of `restic snapshots --json`.
func snapshotCount(reportDir string, name string) string {
	var snapshots []json.RawMessage

	content, err := os.ReadFile(path.Join(reportDir, name, "snapshots"))
	if err == nil {
		err = json.Unmarshal(content, &snapshots)
	}

	switch {
	case err != nil:
		return "    · snapshots: not synced ⁉️"
	case len(snapshots) > 0:
		return "    · snapshots: " + strconv.Itoa(len(snapshots)) + " 😎"
	default:
		return "    · snapshots: 0 ❌"
	}
}
