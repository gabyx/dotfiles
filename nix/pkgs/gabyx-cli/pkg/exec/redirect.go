package exec

import (
	"os"
	"syscall"

	"github.com/gabyx/quitsh/pkg/errors"
)

// RedirectOutput truncates the file `file` and points stdout and stderr
// (file descriptors 1 and 2) to it, like `exec >file 2>&1` in a shell.
// The logger and all started commands then write to `file`.
func RedirectOutput(file string) error {
	f, err := os.Create(file)
	if err != nil {
		return errors.AddContext(err, "could not create log file '%s'", file)
	}
	defer func() { _ = f.Close() }()

	for _, fd := range []int{int(os.Stdout.Fd()), int(os.Stderr.Fd())} {
		err = syscall.Dup2(int(f.Fd()), fd)
		if err != nil {
			return errors.AddContext(err,
				"could not redirect output to '%s'", file)
		}
	}

	return nil
}
