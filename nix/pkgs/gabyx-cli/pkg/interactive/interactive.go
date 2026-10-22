package interactive

import (
	"os"

	"github.com/gabyx/quitsh/pkg/exec"
)

// Run runs the command `args` with stdin, stdout and stderr attached
// to the terminal. The environment variables `env` are added.
func Run(env []string, args ...string) error {
	return exec.NewCmdCtxBuilder().
		Env(env...).
		Build().
		WithStdin(os.Stdin).
		Check(args...)
}
