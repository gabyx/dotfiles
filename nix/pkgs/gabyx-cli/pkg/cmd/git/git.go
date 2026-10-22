package gitcmd

import (
	"github.com/spf13/cobra"
)

func AddCmd(root *cobra.Command) {
	gitCmd := &cobra.Command{
		Use:   "git",
		Short: "Git commands.",
	}

	addDeleteMergedBranchesCmd(gitCmd)
	addDeleteBranchesOlderThanWeeksCmd(gitCmd)

	root.AddCommand(gitCmd)
}
