package config

import (
	"github.com/gabyx/quitsh/pkg/common"
	"github.com/gabyx/quitsh/pkg/runner/config"
)

type (
	TestSettings struct {
		// The build type.
		BuildType common.BuildType `yaml:"buildType"`
		// The environment type.
		EnvironmentType common.EnvironmentType `yaml:"environmentType"`

		// Show the test log of the tests.
		ShowTestLog bool `yaml:"showTestLog"`

		// Additional arguments forwarded to the test tool.
		Args []string `yaml:"args"`

		// Additional arguments forwarded to the test executable.
		TestArgs []string `yaml:"testArgs"`
	}

	wrapITestSettings struct {
		// NOTE: We cannot make `Build()` function and have a `BuildType` type
		// (needs to public due to YAML)
		ref *TestSettings
	}
)

// NewTestSettings constructs a new build setting.
func NewTestSettings(
	buildType common.BuildType,
	showTestLog bool,
	args []string,
) TestSettings {
	return TestSettings{ //nolint:exhaustruct // The other fields are not needed.
		BuildType:   buildType,
		Args:        args,
		ShowTestLog: showTestLog,
	}
}

func (c *wrapITestSettings) BuildType() common.BuildType {
	return c.ref.BuildType
}
func (c *wrapITestSettings) ShowTestLog() bool {
	return c.ref.ShowTestLog
}
func (c *wrapITestSettings) Args() []string {
	return c.ref.Args
}

func (c *wrapITestSettings) TestArgs() []string {
	return c.ref.TestArgs
}

// WrapToITestSettings returns a interface for the quitsh runners.
func (b *TestSettings) WrapToITestSettings() config.ITestSettings {
	return &wrapITestSettings{ref: b}
}
