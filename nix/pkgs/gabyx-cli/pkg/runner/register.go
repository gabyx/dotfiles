package runner

import (
	"gabyx-cli/pkg/runner/config"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/gabyx/quitsh/pkg/runner/factory"

	containerfilerunner "github.com/gabyx/quitsh/pkg/runner/containerfile"
	coveragerunner "github.com/gabyx/quitsh/pkg/runner/coverage"
	execRunner "github.com/gabyx/quitsh/pkg/runner/exec"
	"github.com/gabyx/quitsh/pkg/runner/gitdiffrunner"
	gorunner "github.com/gabyx/quitsh/pkg/runner/go"
	nixrunner "github.com/gabyx/quitsh/pkg/runner/nix"
	symlinkrunner "github.com/gabyx/quitsh/pkg/runner/symlinks"
	trivyrunner "github.com/gabyx/quitsh/pkg/runner/trivy"
)

func RegisterAll(
	lintSettings *config.LintSettings,
	buildSettings *config.BuildSettings,
	testSettings *config.TestSettings,
	imageSettings *config.ImageSettings,
	nixSettings *config.NixSettings,
	factory factory.IFactory,
) {
	log.Trace("Register all runners.")
	var err error

	e := execRunner.Register(buildSettings.WrapToIBuildSettings(), factory, true)
	err = errors.Combine(err, e)

	e = gorunner.RegisterBuild(buildSettings.WrapToIBuildSettings(), factory, true)
	err = errors.Combine(err, e)

	e = gorunner.RegisterTest(testSettings.WrapToITestSettings(), factory, true)
	err = errors.Combine(err, e)

	e = gorunner.RegisterLint(&lintSettings.LintSettings, factory, true)
	err = errors.Combine(err, e)

	e = coveragerunner.Register(testSettings.WrapToITestSettings(), factory)
	err = errors.Combine(err, e)

	e = trivyrunner.Register(&lintSettings.LintSettings, factory)
	err = errors.Combine(err, e)

	e = symlinkrunner.Register(&lintSettings.LintSettings, factory)
	err = errors.Combine(err, e)

	e = nixrunner.Register(imageSettings, nixSettings, factory)
	err = errors.Combine(err, e)
	e = containerfilerunner.Register(imageSettings, factory)
	err = errors.Combine(err, e)

	e = gitdiffrunner.Register(factory, nixSettings)
	err = errors.Combine(err, e)

	if err != nil {
		log.PanicE(err, "Could not register runners")
	}
}
