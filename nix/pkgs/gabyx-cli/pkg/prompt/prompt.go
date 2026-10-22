package prompt

import (
	"os"

	"charm.land/huh/v2"
	"github.com/gabyx/quitsh/pkg/errors"
)

// Get prompts for a input. The prompt is rendered on stderr
// to keep stdout free.
func Get(title string, hidden bool) (secret string, err error) {
	input := huh.NewInput().
		Title(title).
		Validate(func(s string) error {
			if s == "" {
				return errors.New("empty input")
			}

			return nil
		}).
		Value(&secret)

	if hidden {
		input.EchoMode(huh.EchoModePassword)
	}

	err = huh.NewForm(huh.NewGroup(input)).
		WithOutput(os.Stderr).
		WithShowHelp(false).
		Run()

	return secret, err
}
