package gitcmd

import (
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"strings"

	"charm.land/huh/v2"
	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/exec/git"
	fs "github.com/gabyx/quitsh/pkg/filesystem"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

const longDescCleanRepos = `
    Find all Git repositories below 'root-dir' (default: '.') and select
    interactively which ones get a 'git clean -X -d' (remove all ignored files
    and directories).
    Directories below a found repository are not searched further, e.g.
    nested repositories and submodules are not listed.
`

const cleanReposSelectHeight = 20

type cleanReposArgs struct {
	force bool
}

func defaultExcludePatterns() []string {
	return []string{
		"!**/.env",
		"!**/.env.yaml",
		"!**/*.user.*",
	}
}

func addCleanReposCmd(parent *cobra.Command) {
	var args cleanReposArgs

	cmd := &cobra.Command{
		Use:   "clean-repos [root-dir]",
		Short: "Find Git repositories and run 'git clean -X -d' on the selected ones.",
		Long:  longDescCleanRepos,
		Args:  cobra.MaximumNArgs(1),
		RunE: func(_cmd *cobra.Command, posArgs []string) error {
			rootDir := "."
			if len(posArgs) > 0 {
				rootDir = posArgs[0]
			}

			return cleanRepos(&args, rootDir)
		},
	}

	cmd.Flags().
		BoolVarP(&args.force,
			"force", "f", false, "Instead of doing a dry-run really remove the files.")

	parent.AddCommand(cmd)
}

func cleanRepos(args *cleanReposArgs, rootDir string) error {
	log.Info("Searching for Git repositories.", "root", rootDir)
	repos, err := findGitRepos(rootDir)
	if err != nil {
		return err
	}

	if len(repos) == 0 {
		log.Info("No Git repositories found.")

		return nil
	}

	selected, err := selectRepos(rootDir, repos, args.force)
	if err != nil {
		return err
	}

	if len(selected) == 0 {
		log.Info("No repositories selected.")

		return nil
	}

	for _, repo := range selected {
		var e error
		gitx := git.NewCtx(repo, func(builder *exec.CmdContextBuilder) {
			builder.NoQuiet()
		})

		cmd := []string{"clean", "-f", "-X", "-d"}
		for _, p := range defaultExcludePatterns() {
			cmd = append(cmd, "-e", p)
		}

		var files []string
		if args.force {
			files, e = gitx.GetSplit(cmd...)
		} else {
			files, e = gitx.GetSplit(append(cmd, "-n")...)
		}

		if e != nil {
			log.ErrorE(e, "Could not run 'git clean'.", "repo", repo)
			err = errors.Combine(err, e)

			continue
		}

		if len(files) == 0 {
			log.Info("Nothing to clean.", "repo", repo)

			continue
		}

		b := strings.Builder{}
		for _, f := range files {
			fmt.Fprintf(&b, " - '%s' \n", f)
		}

		if args.force {
			log.Infof("Cleaned files in '%v':\n%s", repo, b.String())
		} else {
			log.Infof("Would clean files in '%v':\n%s", repo, b.String())
		}
	}

	if !args.force {
		log.Info("Run with '--force' to remove.")
	}

	return err
}

// findGitRepos returns all directories below `rootDir` which contain a `.git`
// directory or file. It does not descend into found repositories.
func findGitRepos(rootDir string) ([]string, error) {
	rootDir = filepath.Clean(rootDir)

	isRepo := func(dir string) bool {
		_, e := os.Lstat(filepath.Join(dir, ".git"))

		return e == nil
	}

	repos, _, err := fs.FindPaths(rootDir,
		fs.WithReportOnlyDirs(true),
		fs.WithWalkDirFilterDefault(true),
		fs.WithWalkDirFilter(func(p string, _ os.DirEntry) bool {
			return p == rootDir || !isRepo(filepath.Dir(p))
		}, true),
		fs.WithPathFilter(func(p string, _ os.DirEntry) bool {
			return isRepo(p)
		}, true))
	if err != nil {
		return nil, err
	}

	// The walk is concurrent, the order is not deterministic.
	slices.Sort(repos)

	return repos, nil
}

// selectRepos lets the user select a subset of `repos`.
// Options are shown relative to `rootDir`.
func selectRepos(rootDir string, repos []string, force bool) (selected []string, err error) {
	options := make([]huh.Option[string], 0, len(repos))
	for _, r := range repos {
		name, e := filepath.Rel(rootDir, r)
		if e != nil {
			return nil, errors.AddContext(e, "repository not under root '%v'", rootDir)
		}
		options = append(options, huh.NewOption(name, r))
	}

	title := "Select repositories for 'git clean' "
	if !force {
		title += "[dry run]"
	}

	sel := huh.NewMultiSelect[string]().
		Title(title + ":").
		Options(options...).
		Filterable(true).
		Height(cleanReposSelectHeight).
		Value(&selected)

	err = huh.NewForm(huh.NewGroup(sel)).
		WithOutput(os.Stderr).
		Run()

	return selected, err
}
