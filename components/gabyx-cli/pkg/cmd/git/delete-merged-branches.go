package gitcmd

import (
	"slices"
	"strings"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/exec/git"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

const longDescDeleteMerged = `
    Delete local branches (and their remote branch) which are
    - merged into the main branch,
    - squash-merged into the main branch,
    - tracking an upstream branch which is gone on the remote.
`

//nolint:gochecknoglobals // Allowed for constant definitions.
var protectedBranches = []string{"main", "master", "develop"}

type deleteMergedArgs struct {
	force   bool
	noFetch bool
	remote  string
}

type upstream struct {
	remote string
	branch string
}

type candidate struct {
	reason   string
	upstream *upstream
}

func addDeleteMergedBranchesCmd(parent *cobra.Command) {
	var args deleteMergedArgs

	cmd := &cobra.Command{
		Use:   "delete-merged-branches [main-branch]",
		Short: "Delete merged, squash-merged and gone branches (default main branch: 'main').",
		Long:  longDescDeleteMerged,
		Args:  cobra.MaximumNArgs(1),
		RunE: func(_cmd *cobra.Command, posArgs []string) error {
			mainBranch := "main"
			if len(posArgs) > 0 {
				mainBranch = posArgs[0]
			}

			return deleteMergedBranches(&args, mainBranch)
		},
	}

	cmd.Flags().
		BoolVarP(&args.force,
			"force", "f", false, "Instead of doing a dry-run really delete the branches.")
	cmd.Flags().
		StringVarP(&args.remote,
			"remote", "r", "origin", "The remote to fetch from and delete branches on.")
	cmd.Flags().
		BoolVar(&args.noFetch,
			"no-fetch", false, "Do not fetch and prune the remote first.")

	parent.AddCommand(cmd)
}

func deleteMergedBranches(args *deleteMergedArgs, mainBranch string) error {
	gitx := git.NewCtx(".")

	if sha, err := gitx.LocalBranchExists(mainBranch); err != nil {
		return err
	} else if sha == "" {
		return errors.New("main branch '%s' does not exist", mainBranch)
	}

	if !args.noFetch {
		log.Info("Fetching and pruning remote.", "remote", args.remote)
		err := gitx.Check("fetch", "--prune", "-q", args.remote)
		if err != nil {
			log.WarnE(err, "Could not fetch remote, '[gone]' detection might be stale.")
		}
	}

	candidates, err := collectCandidates(gitx, mainBranch)
	if err != nil {
		return err
	}

	if len(candidates) == 0 {
		log.Info("No branches to delete.")

		return nil
	}

	err = setUpstreams(gitx, args.remote, candidates)
	if err != nil {
		return err
	}

	return deleteCandidates(gitx, candidates, mainBranch, args.force)
}

// collectCandidates returns all non-protected branches which are gone,
// merged or squash-merged into `mainBranch`.
func collectCandidates(gitx git.Context, mainBranch string) (map[string]*candidate, error) {
	protected := append(slices.Clone(protectedBranches), mainBranch)

	candidates := map[string]*candidate{}
	add := func(branch string, reason string) {
		if branch == "" || slices.Contains(protected, branch) {
			return
		}
		if _, exists := candidates[branch]; !exists {
			candidates[branch] = &candidate{reason: reason, upstream: nil}
		}
	}

	gone, err := gitx.GetSplit("for-each-ref", "refs/heads/",
		"--format=%(if:equals=[gone])%(upstream:track)%(then)%(refname:short)%(end)")
	if err != nil {
		return nil, err
	}
	for _, b := range gone {
		add(b, "upstream is gone")
	}

	merged, err := gitx.GetSplit("for-each-ref", "refs/heads/",
		"--merged", mainBranch, "--format=%(refname:short)")
	if err != nil {
		return nil, err
	}
	for _, b := range merged {
		add(b, "merged into '"+mainBranch+"'")
	}

	notMerged, err := gitx.GetSplit("for-each-ref", "refs/heads/",
		"--no-merged", mainBranch, "--format=%(refname:short)")
	if err != nil {
		return nil, err
	}
	for _, b := range notMerged {
		if slices.Contains(protected, b) || candidates[b] != nil {
			continue
		}

		if isSquashMerged(gitx, mainBranch, b) {
			add(b, "squash-merged into '"+mainBranch+"'")
		}
	}

	return candidates, nil
}

// isSquashMerged creates a dangling commit which squashes the whole `branch`
// onto the merge-base and checks if an equivalent patch is in `mainBranch`.
func isSquashMerged(gitx git.Context, mainBranch string, branch string) bool {
	log.Debug("Checking branch for squash-merge.", "branch", branch)

	mergeBase, err := gitx.Get("merge-base", mainBranch, branch)
	if err != nil {
		log.WarnE(err, "Could not get merge-base.", "branch", branch)

		return false
	}

	commitx := git.NewCtx(".", func(b *exec.CmdContextBuilder) {
		b.Quiet().Env(
			"GIT_AUTHOR_NAME=_", "GIT_AUTHOR_EMAIL=_",
			"GIT_COMMITTER_NAME=_", "GIT_COMMITTER_EMAIL=_")
	})
	squashed, err := commitx.Get("commit-tree", branch+"^{tree}", "-p", mergeBase, "-m", "_")
	if err != nil {
		log.WarnE(err, "Could not create a squash commit.", "branch", branch)

		return false
	}

	out, err := gitx.Get("cherry", mainBranch, squashed)
	if err != nil {
		log.WarnE(err, "Could not run 'git cherry'.", "branch", branch)

		return false
	}

	return strings.HasPrefix(out, "-")
}

// setUpstreams sets the upstream on all candidates which track
// an existing branch on `remote`.
func setUpstreams(gitx git.Context, remote string, candidates map[string]*candidate) error {
	const nFields = 4

	lines, err := gitx.GetSplit("for-each-ref", "refs/heads/",
		"--format=%(refname:short)\t%(upstream:remotename)\t%(upstream:lstrip=3)\t%(upstream:track)")
	if err != nil {
		return err
	}

	for _, l := range lines {
		f := strings.SplitN(l, "\t", nFields)
		for len(f) < nFields {
			f = append(f, "")
		}

		c := candidates[f[0]]
		if c == nil || f[1] != remote || f[2] == "" || f[3] == "[gone]" {
			continue
		}

		c.upstream = &upstream{remote: f[1], branch: f[2]}
	}

	return nil
}

func deleteCandidates(
	gitx git.Context,
	candidates map[string]*candidate,
	mainBranch string,
	force bool,
) error {
	current, err := gitx.Get("branch", "--show-current")
	if err != nil {
		return err
	}

	if force && candidates[current] != nil {
		log.Info("Current branch will be deleted, checking out main branch.",
			"branch", current, "main", mainBranch)

		err = gitx.Check("checkout", "-q", mainBranch)
		if err != nil {
			return err
		}
	}

	branches := make([]string, 0, len(candidates))
	for b := range candidates {
		branches = append(branches, b)
	}
	slices.Sort(branches)

	for _, b := range branches {
		c := candidates[b]

		remoteRef := ""
		if c.upstream != nil {
			remoteRef = c.upstream.remote + "/" + c.upstream.branch
		}

		if !force {
			log.Info("Dry Run: Would delete branch.",
				"branch", b, "reason", c.reason, "remote", remoteRef)

			continue
		}

		log.Info("Deleting branch.", "branch", b, "reason", c.reason)
		err = gitx.Check("branch", "-D", "-q", b)
		if err != nil {
			log.ErrorE(err, "Could not delete branch.", "branch", b)

			continue
		}

		if c.upstream != nil {
			log.Info("Deleting remote branch.", "remote", remoteRef)
			err = gitx.Check("push", "-q", "--delete", c.upstream.remote, c.upstream.branch)
			if err != nil {
				log.WarnE(err, "Could not delete remote branch.", "remote", remoteRef)
			}
		}
	}

	if !force {
		log.Info("Run with '--force' to delete.")
	}

	return nil
}
