package main

import (
	"os"

	buildCmd "gabyx-cli/cmd/dev/cmd/build"
	lintCmd "gabyx-cli/cmd/dev/cmd/lint"
	testCmd "gabyx-cli/cmd/dev/cmd/test"

	"gabyx-cli/pkg/build"
	configdev "gabyx-cli/pkg/config-dev"
	"gabyx-cli/pkg/runner"

	"github.com/gabyx/quitsh/pkg/cli"
	"github.com/gabyx/quitsh/pkg/component/stage"
	"github.com/gabyx/quitsh/pkg/log"

	cleanCmd "github.com/gabyx/quitsh/pkg/cli/cmd/clean"
	configCmd "github.com/gabyx/quitsh/pkg/cli/cmd/config"
	execRunnerCmd "github.com/gabyx/quitsh/pkg/cli/cmd/exec-runner"
	execTargetCmd "github.com/gabyx/quitsh/pkg/cli/cmd/exec-target"
	listCmd "github.com/gabyx/quitsh/pkg/cli/cmd/list"
	nixCmd "github.com/gabyx/quitsh/pkg/cli/cmd/nix"
)

func main() {
	err := log.Setup("info") // Level will be set at startup.
	if err != nil {
		log.PanicE(err, "Could not setup logger.")
	}

	conf := configdev.New()

	cl, err := cli.New(
		&conf.Commands.Root,
		&conf,
		cli.WithName("gabyx-dev"),
		cli.WithDescription("Personal build tooling for gabyx 🌻."),
		cli.WithVersion(build.Version()),
		cli.WithStages(stage.AllStages()...),
		cli.WithTargetToStageMapperDefault(),
		cli.WithSignalContext(true),
	)
	log.PanicE(err, "Could not initialize CLI app.")

	defer func() {
		e := cl.Shutdown()
		log.WarnE(e, "Could not shutdown CLI app.")
		if err != nil {
			os.Exit(1)
		}
	}()

	// Quitsh commands.
	configCmd.AddCmd(cl.RootCmd(), &conf)
	execRunnerCmd.AddCmd(cl, cl.RootCmd(), &conf.Commands.DispatchArgs)
	execTargetCmd.AddCmd(cl, cl.RootCmd(), &conf.Commands.ExecArgs)
	listCmd.AddCmd(cl, cl.RootCmd())
	cleanCmd.AddCmd(cl)
	nixCmd.AddCmd(cl, cl.RootCmd(), &conf.Nix)

	buildCmd.AddCmd(cl, &conf.Build, &conf.Commands.ExecArgs)
	lintCmd.AddCmd(cl, &conf.Lint, &conf.Commands.ExecArgs)
	testCmd.AddCmd(cl, &conf.Test, &conf.Commands.ExecArgs)

	runner.RegisterAll(
		&conf.Lint,
		&conf.Build,
		&conf.Test,
		&conf.Image,
		&conf.Nix,
		cl.RunnerFactory(),
	)

	err = cl.Run()
}
