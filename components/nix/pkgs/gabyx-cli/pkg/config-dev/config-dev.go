package configdev

import (
	"gabyx-cli/pkg/runner/config"

	"github.com/creasty/defaults"
	rootcmd "github.com/gabyx/quitsh/pkg/cli/cmd/root"
	qConfig "github.com/gabyx/quitsh/pkg/config"
	"github.com/gabyx/quitsh/pkg/dag"
	"github.com/gabyx/quitsh/pkg/log"
	qRunnerConfig "github.com/gabyx/quitsh/pkg/runner/config"
	"github.com/gabyx/quitsh/pkg/toolchain"
	"github.com/go-playground/validator/v10"
	clone "github.com/huandu/go-clone/generic"
)

type (
	CommandArgs struct {
		// Arguments needed to make the root command in `quitsh` work.
		Root rootcmd.Args `yaml:"root"`

		// Arguments needed to make the `execute`
		// command in `quitsh` work. This is used when `quitsh` dispatches over a toolchain
		// and needs to call it self (see `exec.AddCmd`).
		DispatchArgs toolchain.DispatchArgs `yaml:"toolchainDispatch"`

		// Exec arguments.
		ExecArgs dag.ExecArgs `yaml:"execArgs"`
	}

	Config struct {
		// All command arguments of the `gabyx` CLI.
		Commands CommandArgs `yaml:"commands"`

		// Some Nix settings.
		Nix qRunnerConfig.NixSettings `yaml:"nix"`

		// The build settings which get copied and injected into the runners:
		// - `custodian::build-go`
		Build config.BuildSettings `yaml:"build"`

		// The lint settings which get copied and injected into the runners:
		// - `custodian::lint-go`
		Lint config.LintSettings `yaml:"lint"`

		// The test settings which get copied and injected into the runners:
		// - `custodian::test-go`
		Test config.TestSettings `yaml:"test"`

		// The images settings which get copied and injected into the runners:
		// - `custodian::image-nix`
		// - `custodian::image-containerfile`
		Image config.ImageSettings `yaml:"image"`
	}
)

// SetDefaults implements [defaults.Setter].
func (c *Config) SetDefaults() {
	// The packages are defined in the root flake.
	c.Nix.FlakeDirRel = "."
}

// New returns a [qConfig.IConfig] with default values.
func New() (args Config) {
	err := defaults.Set(&args)
	log.PanicE(err, "could not default initialize config")

	return
}

// Clone implements [qConfig.IConfig].
func (c *Config) Clone() qConfig.IConfig {
	return clone.Clone(c)
}

// Validate implements [config.IConfig] interface.
func (c *Config) Validate() error {
	return validator.New().StructExcept(c, "Commands")
}
