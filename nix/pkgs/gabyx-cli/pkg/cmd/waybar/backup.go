package waybarcmd

import (
	"encoding/json"
	"os"
	"path"
	"strconv"
	"strings"
	"time"

	gexec "gabyx-cli/pkg/exec"

	qStr "github.com/gabyx/quitsh/pkg/common/strings"
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
	tooltip.WriteString("Backup Status:\n")
	for _, l := range lines {
		tooltip.WriteString(l)
		tooltip.WriteString("\n")
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

	state, msg := lastStatus(reportDir, name)

	switch state {
	case backupSuccess:
		return state, Bullet + " " + msg
	case backupFailure:
		return state, Bullet + " " + msg
	default:
		log.Debug("Could not determine status.", "backup", name)

		return backupFailure, "· ⁉️ '" + name + "'"
	}
}

// unitExists returns `true` if the systemd unit `unit` is loaded.
func unitExists(unit string) bool {
	state, err := exec.NewCommandCtx(".").
		Get(gexec.ExtCmdSystemctl, "show", "-p", "LoadState", "--value", unit)

	return err == nil && state == "loaded"
}

// unitRunning returns `true` if the systemd unit `unit` is
// neither inactive nor failed.
func unitRunning(unit string) bool {
	// `systemctl is-active` exits non-zero if the unit is not active.
	state, _ := exec.NewCommandCtx(".").
		GetWithEC(func(*exec.CmdError) error { return nil }, gexec.ExtCmdSystemctl, "is-active", unit)

	return !strings.Contains(state, "inactive") && !strings.Contains(state, "failed")
}

// lastStatus returns the last line of the status file of backup `name`
// broken into lines of `backupStatusWidth` characters.
func lastStatus(reportDir string, name string) (state backupState, msg string) {
	file := path.Join(reportDir, name, "status")
	log.Infof("Reading '%s'", file)
	state = backupNone

	content, err := os.ReadFile(file)
	if err != nil {
		log.ErrorE(err, "could not read file")

		return
	}

	lines := qStr.SplitLines(strings.TrimSpace(string(content)))
	last := lines[len(lines)-1]
	log.Infof("Last run: %v", last)

	if strings.Contains(last, backupSuccess.String()) {
		state = backupSuccess
	} else if strings.Contains(last, backupFailure.String()) {
		state = backupFailure
	}

	msg = breakLine(last, backupStatusWidth)

	return
}

// breakLine appends `\n  ` after every `width` characters of `s`.
func breakLine(s string, width int) string {
	runes := []rune(s)
	b := strings.Builder{}

	for len(runes) >= width {
		b.WriteString(string(runes[:width]))
		b.WriteString("\n  ")
		runes = runes[width:]
	}
	b.WriteString(string(runes))

	return b.String()
}

// snapshotCount returns the line with the number of snapshots of backup `name`.
// The snapshots file is the output of `restic snapshots --json`.
func snapshotCount(reportDir string, name string) string {
	file := path.Join(reportDir, name, "snapshots")
	log.Infof("Reading '%s'", file)

	type D struct {
		Time time.Time `json:"time"`
	}
	var snapshots []D

	content, err := os.ReadFile(file)
	if err != nil {
		log.ErrorE(err, "could not read file")

		return ""
	}

	err = json.Unmarshal(content, &snapshots)

	switch {
	case err != nil:
		return "    " + Bullet + " snapshots: not synced ⁉️"
	case len(snapshots) > 0:
		msg := "    " + Bullet + " snapshots: " + strconv.Itoa(len(snapshots)) + " 😎"
		msg += "    " + Bullet + " latest: " + snapshots[0].Time.Format(time.RFC1123)

		return msg
	default:
		return "    " + Bullet + " snapshots: 0 ❌"
	}
}
