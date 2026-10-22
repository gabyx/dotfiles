package config

import (
	"github.com/creasty/defaults"
	rootcmd "github.com/gabyx/quitsh/pkg/cli/cmd/root"
	qConfig "github.com/gabyx/quitsh/pkg/config"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/go-playground/validator/v10"
	clone "github.com/huandu/go-clone/generic"
)

type (
	CommandArgs struct {
		// Arguments needed to make the root command in `quitsh` work.
		Root rootcmd.Args `yaml:"root"`
	}

	Config struct {
		// All command arguments of the `gabyx` CLI.
		Commands CommandArgs `yaml:"commands"`
	}
)

// SetDefaults implements [defaults.Setter].
func (c *Config) SetDefaults() {}

// New returns a [config.IConfig] with default values.
func New() (args Config) {
	err := defaults.Set(&args)
	log.PanicE(err, "could not default initialize config")

	return
}

// Clone implements [config.IConfig].
func (c *Config) Clone() qConfig.IConfig {
	return clone.Clone(c)
}

// Validate implements [config.IConfig] interface.
func (c *Config) Validate() error {
	return validator.New().StructExcept(c, "Commands")
}
