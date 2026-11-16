package main

import (
	"os"

	"gabyx-cli/pkg/build"
	"gabyx-cli/pkg/cmd"
	"gabyx-cli/pkg/config"

	"github.com/gabyx/quitsh/pkg/cli"
	"github.com/gabyx/quitsh/pkg/log"
)

func main() {
	err := log.Setup("info") // Level will be set at startup.
	if err != nil {
		log.PanicE(err, "Could not setup logger.")
	}

	conf := config.New()

	cl, err := cli.New(
		&conf.Commands.Root,
		&conf,
		cli.WithName("gabyx"),
		cli.WithDescription("Personal tooling of gabyx 🌻."),
		cli.WithVersion(build.Version()),
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

	cmd.AddCommands(cl)

	err = cl.Run()
}
