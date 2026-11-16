package filesystemcmd

import (
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"time"

	fs "github.com/gabyx/quitsh/pkg/filesystem"
	"github.com/spf13/cobra"
)

type File struct {
	Path    string
	ModTime time.Time
}

func addFindRecentCmd(parent *cobra.Command) {
	cmd := &cobra.Command{
		Use:   "find-recent <dir> [glob]...",
		Short: "List files in a directory sorted by modification time (oldest first).",
		Long: "List all regular files in `dir` whose path relative to `dir` matches " +
			"any doublestar glob `glob` (default: '**'), sorted by modification time " +
			"with the newest file last.",
		Args: cobra.MinimumNArgs(1),
		RunE: func(_cmd *cobra.Command, args []string) error {
			files, err := FindRecent(args[0], args[1:]...)
			if err != nil {
				return err
			}

			for _, f := range files {
				fmt.Fprintf(os.Stdout, "%s %s\n", f.ModTime.Format("02-Jan-2006 15:04:05"), f.Path)
			}

			return nil
		},
	}

	parent.AddCommand(cmd)
}

// FindRecent returns all regular files in `dir` whose path relative to `dir`
// matches any doublestar glob in `globs` (all files if empty), sorted by
// modification time (oldest first).
func FindRecent(dir string, globs ...string) ([]File, error) {
	paths, _, err := fs.FindFiles(dir,
		fs.WithOnlyRegularFiles(true),
		fs.WithPathFilter(func(p string, _ os.DirEntry) bool {
			rel, e := filepath.Rel(dir, p)
			if e != nil {
				return false
			}

			return fs.MatchByPatterns(rel, globs, nil)
		}, true))
	if err != nil {
		return nil, err
	}

	files := make([]File, 0, len(paths))
	for _, p := range paths {
		info, e := os.Stat(p)
		if e != nil {
			return nil, e
		}

		files = append(files, File{Path: p, ModTime: info.ModTime()})
	}

	slices.SortFunc(files, func(a, b File) int {
		if c := a.ModTime.Compare(b.ModTime); c != 0 {
			return c
		}

		return strings.Compare(a.Path, b.Path)
	})

	return files, nil
}
