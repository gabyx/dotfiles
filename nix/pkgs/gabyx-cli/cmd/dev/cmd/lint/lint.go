package lint

import (
	"gabyx-cli/pkg/runner/config"

	"github.com/gabyx/quitsh/pkg/cli"
	execstage "github.com/gabyx/quitsh/pkg/cli/cmd/exec-stage"
	"github.com/gabyx/quitsh/pkg/component/stage"
	"github.com/gabyx/quitsh/pkg/dag"

	"github.com/spf13/cobra"
)

func AddCmd(
	cl cli.ICLI,
	lintSettings *config.LintSettings,
	execArgs *dag.ExecArgs,
) {
	execstage.AddCmdAlias(cl, cl.RootCmd(), stage.Lint, execArgs, execstage.WithModifications(
		func(cmd *cobra.Command) {
			cmd.Flags().
				BoolVar(&lintSettings.Fix, "fix", lintSettings.Fix, "Try to fix all linting issues automatically.")
		},
	))
}
