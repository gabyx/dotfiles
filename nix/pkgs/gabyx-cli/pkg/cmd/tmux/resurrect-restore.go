package tmuxcmd

import (
	"os"
	"path"
	"strconv"
	"time"

	filesystemcmd "gabyx-cli/pkg/cmd/filesystem"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

const (
	resurrectGlob = "tmux_*"
	keepDuration  = 7 * 24 * time.Hour
)

const longDescResurrectRestore = `
    Restore 'tmux' with the 'index'-th last saved resurrect file by linking it
    to 'last'. Resurrect files older than one week are removed.
    Afterwards trigger resurrect with 'Tmux-Leader + Ctrl+R'.
`

func addResurrectRestoreCmd(parent *cobra.Command) {
	cmd := &cobra.Command{
		Use:   "resurrect-restore [index]",
		Short: "Restore the 'index'-th last saved resurrect file (default: 1).",
		Long:  longDescResurrectRestore,
		Args:  cobra.MaximumNArgs(1),
		RunE: func(_cmd *cobra.Command, args []string) error {
			index := 1
			if len(args) > 0 {
				i, err := strconv.Atoi(args[0])
				if err != nil || i < 1 {
					return errors.New("index '%s' must be a positive number", args[0])
				}
				index = i
			}

			return resurrectRestore(index)
		},
	}

	parent.AddCommand(cmd)
}

func resurrectRestore(index int) error {
	home, err := os.UserHomeDir()
	if err != nil {
		return err
	}
	dir := path.Join(home, ".local", "share", "tmux", "resurrect")

	files, err := filesystemcmd.FindRecent(dir, resurrectGlob)
	if err != nil {
		return err
	}

	var kept []filesystemcmd.File
	for _, f := range files {
		if time.Since(f.ModTime) <= keepDuration {
			kept = append(kept, f)

			continue
		}

		log.Debug("Removing old resurrect file.", "path", f.Path)
		if e := os.Remove(f.Path); e != nil {
			log.ErrorE(e, "Could not clean up.", "path", f.Path)
		}
	}

	if len(kept) == 0 {
		return errors.New("no resurrect file in '%s'", dir)
	}

	last := kept[max(0, len(kept)-index):]
	for _, f := range last {
		log.Info("Resurrect file.", "path", f.Path, "modified", f.ModTime.Format(time.DateTime))
	}
	lastFile := last[0].Path

	content, err := os.ReadFile(lastFile)
	if err != nil {
		return err
	}
	log.Info("Last file contains:", "path", lastFile)
	_, _ = os.Stdout.Write(content)

	log.Info("Restore last file.")
	link := path.Join(dir, "last")
	_ = os.Remove(link)

	err = os.Symlink(lastFile, link)
	if err != nil {
		log.ErrorE(err, "Could not symlink last file.", "path", link)
	}

	return nil
}
