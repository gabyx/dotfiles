package build

import (
	"fmt"
	"gabyx-cli/pkg/runner/config"

	"github.com/gabyx/quitsh/pkg/cli"
	execstage "github.com/gabyx/quitsh/pkg/cli/cmd/exec-stage"
	"github.com/gabyx/quitsh/pkg/common"
	"github.com/gabyx/quitsh/pkg/component/stage"
	"github.com/gabyx/quitsh/pkg/dag"

	"github.com/spf13/cobra"
	"github.com/spf13/pflag"
)

func AddCmd(
	cl cli.ICLI,
	buildSettings *config.BuildSettings,
	execArgs *dag.ExecArgs,
) {
	execstage.AddCmdAlias(cl, cl.RootCmd(), stage.Build, execArgs, execstage.WithModifications(
		func(cmd *cobra.Command) {
			cmd.PreRun = func(cmd *cobra.Command, _ []string) {
				adjustDefaultValues(cmd, buildSettings)
			}

			cmd.Flags().
				VarP(&buildSettings.BuildType,
					"build-type", "b",
					fmt.Sprintf("The build type (set by env. type if not set) (%v).", common.GetAllBuildTypes()),
				)
			cmd.Flags().
				VarP(&buildSettings.EnvironmentType,
					"env-type", "e", fmt.Sprintf("The environment type. (%s)", common.GetEnvTypesHelp()))

			cmd.Flags().
				BoolVar(&buildSettings.Coverage,
					"coverage", false, "Enable coverage for the build.")
		},
	))
}

func adjustDefaultValues(cmd *cobra.Command, setts *config.BuildSettings) {
	// Adjust the `BuildType` if its not set.
	cmd.Flags().VisitAll(func(flag *pflag.Flag) {
		if flag.Name == "build-type" && !flag.Changed {
			setts.BuildType = common.NewBuildTypeFromEnv(setts.EnvironmentType)
		}
	})
}
