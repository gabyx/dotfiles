package interactive

import (
	"os"
	osexec "os/exec"
	"syscall"

	"github.com/gabyx/quitsh/pkg/errors"
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

// Exec replaces the current process with the command `args` (like `exec` in a shell).
// The environment variables `env` are added. It only returns on error.
func Exec(env []string, args ...string) error {
	if len(args) == 0 {
		return errors.New("no command to execute")
	}

	bin, err := osexec.LookPath(args[0])
	if err != nil {
		return err
	}

	err = syscall.Exec(bin, args, append(os.Environ(), env...))

	return errors.AddContext(err, "could not execute '%s'", bin)
}
