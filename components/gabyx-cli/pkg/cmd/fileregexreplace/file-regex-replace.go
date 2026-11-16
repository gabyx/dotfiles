package fileregexreplacecmd

import (
	"io/fs"
	"os"
	"path"
	"path/filepath"
	"regexp"
	"runtime"
	"sync/atomic"
	"unicode/utf8"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec/git"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
	"golang.org/x/sync/errgroup"
)

const defaultExclude = "(.*/)?.git/.*"

const longDescReplace = `
    Replaces Perl substitutions 's<d>pattern<d>replacement<d>flags' (flags: 'gsmix')
    in all files in 'dir'. Each file is read as a whole and the substitutions
    are applied in the given order. Include and exclude regexes are matched
    from the start of the file path. Files which are not valid UTF-8 are skipped.
`

type replaceArgs struct {
	regexes      []string
	includes     []string
	excludes     []string
	gitFilesOnly bool
	force        bool
	verbose      bool
}

func AddCmd(root *cobra.Command) {
	var args replaceArgs

	cmd := &cobra.Command{
		Use:   "file-regex-replace <dir>",
		Short: "Replace regexes in files.",
		Long:  longDescReplace,
		Args:  cobra.ExactArgs(1),
		RunE: func(_cmd *cobra.Command, posArgs []string) error {
			return replaceFiles(&args, posArgs[0])
		},
	}

	cmd.Flags().
		StringArrayVarP(&args.regexes,
			"regex", "r", nil, "Perl substitution to apply (repeatable).")
	_ = cmd.MarkFlagRequired("regex")
	cmd.Flags().
		StringArrayVarP(&args.includes,
			"include", "i", nil, "Include path regex for files (repeatable).")
	cmd.Flags().
		StringArrayVarP(&args.excludes,
			"exclude", "e", nil,
			"Exclude path regex for files (repeatable, always includes '"+defaultExclude+"').")
	cmd.Flags().
		BoolVar(&args.gitFilesOnly,
			"git-files-only", false, "Only consider files tracked by Git.")
	cmd.Flags().
		BoolVarP(&args.force,
			"force", "f", false, "Force the replacements, no dry-run.")
	cmd.Flags().
		BoolVarP(&args.verbose,
			"verbose", "v", false, "Verbose printing.")

	root.AddCommand(cmd)
}

func replaceFiles(args *replaceArgs, dir string) error {
	subs, err := parseSubstitutions(args.regexes)
	if err != nil {
		return err
	}

	log.Info("Substitutions:")
	for i := range subs {
		log.Infof(
			" - '%s' -> '%s', global: '%v'",
			subs[i].regex.String(),
			subs[i].replacement,
			subs[i].global,
		)
	}

	files, err := collectFiles(args, dir)
	if err != nil {
		return err
	}

	if !args.force {
		log.Infof("Dry Run: Replacing in '%d' files.", len(files))
	} else {
		log.Infof("Replacing in '%d' files.", len(files))
	}

	if args.verbose {
		for _, f := range files {
			log.Info("File.", "path", f)
		}
	}

	changed, err := replaceInFiles(files, subs, args.force)
	if err != nil {
		return err
	}

	if !args.force {
		log.Infof("Dry Run: Would change '%d' files.", changed)
	} else {
		log.Infof("Changed '%d' files.", changed)
	}

	return nil
}

func parseSubstitutions(exprs []string) ([]*Substitution, error) {
	subs := make([]*Substitution, 0, len(exprs))
	for _, r := range exprs {
		s, err := ParseSubstitution(r)
		if err != nil {
			return nil, err
		}
		subs = append(subs, s)
	}

	return subs, nil
}

// collectFiles returns all files in `dir` filtered by the include and exclude regexes.
func collectFiles(args *replaceArgs, dir string) ([]string, error) {
	includes, err := compileAnchored(args.includes)
	if err != nil {
		return nil, err
	}

	excludes, err := compileAnchored(append([]string{defaultExclude}, args.excludes...))
	if err != nil {
		return nil, err
	}

	var files []string
	if args.gitFilesOnly {
		files, err = getGitFiles(dir)
	} else {
		files, err = getFiles(dir)
	}
	if err != nil {
		return nil, err
	}

	return filterFiles(files, includes, excludes), nil
}

// replaceInFiles applies all substitutions to all files in parallel
// and returns the number of changed files.
func replaceInFiles(files []string, subs []*Substitution, force bool) (int64, error) {
	var changed atomic.Int64
	g := errgroup.Group{}
	g.SetLimit(runtime.NumCPU())

	for _, f := range files {
		g.Go(func() error {
			c, e := replaceFile(f, subs, force)
			if e != nil {
				return errors.AddContext(e, "could not replace in '%s'", f)
			} else if !c {
				return nil
			}

			changed.Add(1)
			if !force {
				log.Info("Dry Run: Would change file.", "path", f)
			} else {
				log.Info("Changed file.", "path", f)
			}

			return nil
		})
	}

	err := g.Wait()

	return changed.Load(), err
}

// replaceFile applies all substitutions to the file `file` and writes it if
// `force` is set. Returns `true` if the content changed.
func replaceFile(file string, subs []*Substitution, force bool) (bool, error) {
	data, err := os.ReadFile(file)
	if err != nil {
		return false, err
	}

	if !utf8.Valid(data) {
		log.Debug("Skipping non UTF-8 file.", "path", file)

		return false, nil
	}

	content := string(data)
	for _, s := range subs {
		content, err = s.Apply(content)
		if err != nil {
			return false, err
		}
	}

	if content == string(data) {
		return false, nil
	}

	if !force {
		return true, nil
	}

	info, err := os.Stat(file)
	if err != nil {
		return false, err
	}

	return true, os.WriteFile( //nolint:gosec // Writes given files.
		file,
		[]byte(content),
		info.Mode().Perm(),
	)
}

func compileAnchored(patterns []string) ([]*regexp.Regexp, error) {
	regs := make([]*regexp.Regexp, 0, len(patterns))
	for _, p := range patterns {
		r, err := regexp.Compile(`^(?:` + p + `)`)
		if err != nil {
			return nil, errors.AddContext(err, "could not compile regex '%s'", p)
		}
		regs = append(regs, r)
	}

	return regs, nil
}

func filterFiles(files []string, includes, excludes []*regexp.Regexp) []string {
	matchAny := func(regs []*regexp.Regexp, f string) bool {
		for _, r := range regs {
			if r.MatchString(f) {
				return true
			}
		}

		return false
	}

	var res []string
	for _, f := range files {
		if len(includes) != 0 && !matchAny(includes, f) {
			continue
		}

		if matchAny(excludes, f) {
			continue
		}

		res = append(res, f)
	}

	return res
}

func getFiles(dir string) ([]string, error) {
	var files []string

	err := filepath.WalkDir(dir, func(p string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if d.Type().IsRegular() {
			files = append(files, p)
		}

		return nil
	})

	return files, err
}

func getGitFiles(dir string) ([]string, error) {
	gitx := git.NewCtx(dir)

	paths, err := gitx.GetSplit("ls-files", "--exclude-standard")
	if err != nil {
		return nil, err
	}

	files := make([]string, 0, len(paths))
	for _, p := range paths {
		f := path.Join(dir, p)

		info, e := os.Lstat(f)
		if e != nil || !info.Mode().IsRegular() {
			continue
		}

		files = append(files, f)
	}

	return files, nil
}
