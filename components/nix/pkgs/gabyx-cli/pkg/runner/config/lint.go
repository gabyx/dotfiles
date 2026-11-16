package config

import (
	"github.com/gabyx/quitsh/pkg/runner/config"
)

type LintSettings struct {
	config.LintSettings
}

// NewLintSettings constructs a new build setting.
func NewLintSettings() LintSettings {
	return LintSettings{LintSettings: config.NewLintSettings()}
}
