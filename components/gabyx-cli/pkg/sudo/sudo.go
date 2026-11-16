package sudo

import (
	"os"

	gexec "gabyx-cli/pkg/exec"

	"github.com/gabyx/quitsh/pkg/exec"
)

// IsRoot returns `true` if the process runs as root.
func IsRoot() bool {
	return os.Geteuid() == 0
}

// NewCmdCtxBuilder returns a command builder which runs
// the command over `sudo` if the process is not root.
func NewCmdCtxBuilder() exec.CmdContextBuilder {
	b := exec.NewCmdCtxBuilder()
	if !IsRoot() {
		b = b.BaseCmd(gexec.ExtCmdSudo)
	}

	return b
}

// NewCommandCtx returns a command context in `cwd` which runs
// the command over `sudo` if the process is not root.
func NewCommandCtx(cwd string) *exec.CmdContext {
	return NewCmdCtxBuilder().Cwd(cwd).Build()
}
