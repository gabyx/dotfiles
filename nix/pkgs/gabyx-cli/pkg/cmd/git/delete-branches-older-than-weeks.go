package gitcmd

import (
	"fmt"
	"strings"

	"github.com/gabyx/quitsh/pkg/common/set"
	"github.com/gabyx/quitsh/pkg/exec/git"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

const longDescDeleteOlder = `
    Delete local branches which have not received any commit for '--weeks' weeks.
    Unless '--no-remote' is given, a branch is only deleted if no branch
    with the same name exists on the remote.
`

type deleteOlderArgs struct {
	force    bool
	noRemote bool
	remote   string
	weeks    uint
}

func addDeleteBranchesOlderThanWeeksCmd(parent *cobra.Command) {
	var args deleteOlderArgs

	cmd := &cobra.Command{
		Use:   "delete-branches-older-than-weeks",
		Short: "Delete local branches without commits for a number of weeks.",
		Long:  longDescDeleteOlder,
		Args:  cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			return deleteBranchesOlderThanWeeks(&args)
		},
	}

	cmd.Flags().
		BoolVarP(&args.force,
			"force", "f", false, "Instead of doing a dry-run really delete the branches.")
	cmd.Flags().
		BoolVar(&args.noRemote,
			"no-remote", false, "Also delete branches which exist on the remote.")
	cmd.Flags().
		StringVarP(&args.remote,
			"remote", "r", "origin", "The remote to check branches against.")
	cmd.Flags().
		UintVar(&args.weeks,
			"weeks", 8, "The number of weeks without commits.") //nolint:mnd

	parent.AddCommand(cmd)
}

func deleteBranchesOlderThanWeeks(args *deleteOlderArgs) error {
	gitx := git.NewCtx(".")

	log.Info("Fetching and pruning remote.", "remote", args.remote)
	err := gitx.Check("fetch", "--prune", "-q", args.remote)
	if err != nil {
		return err
	}

	remoteBranches := set.NewUnordered[string]()
	if !args.noRemote {
		remoteBranches, err = getRemoteBranches(gitx, args.remote)
		if err != nil {
			return err
		}
	}

	log.Info("Searching for branches without commits.", "weeks", args.weeks)
	stale, err := getStaleBranches(gitx, args.weeks)
	if err != nil {
		return err
	}

	var toDelete []string
	for _, b := range stale {
		if !args.noRemote && remoteBranches.Exists(b) {
			continue
		}

		if !args.force {
			log.Info("Dry Run: Would delete branch.", "branch", b)
		} else {
			log.Info("Delete branch.", "branch", b)
		}
		toDelete = append(toDelete, b)
	}

	if !args.force {
		return nil
	}

	for _, b := range toDelete {
		err = gitx.Check("branch", "-D", "-q", b)
		if err != nil {
			return err
		}
	}

	return nil
}

// getRemoteBranches returns all branch names on `remote`.
func getRemoteBranches(gitx git.Context, remote string) (set.Unordered[string], error) {
	refs, err := gitx.GetSplit("ls-remote", "--heads", remote)
	if err != nil {
		return set.Unordered[string]{}, err
	}

	branches := set.NewUnordered[string]()
	for _, l := range refs {
		_, ref, _ := strings.Cut(l, "\t")
		branches.Insert(strings.TrimPrefix(ref, "refs/heads/"))
	}

	return branches, nil
}

// getStaleBranches returns all local branches except the current one
// which have no commit since `weeks` weeks.
func getStaleBranches(gitx git.Context, weeks uint) ([]string, error) {
	current, err := gitx.Get("branch", "--show-current")
	if err != nil {
		return nil, err
	}

	branches, err := gitx.GetSplit("for-each-ref", "refs/heads/", "--format=%(refname:short)")
	if err != nil {
		return nil, err
	}

	since := fmt.Sprintf("--since=%d weeks ago", weeks)

	var stale []string
	for _, b := range branches {
		if b == current {
			continue
		}

		recent, e := gitx.Get("log", "-1", since, "--format=%H", b, "--")
		if e != nil {
			return nil, e
		} else if recent == "" {
			stale = append(stale, b)
		}
	}

	return stale, nil
}
