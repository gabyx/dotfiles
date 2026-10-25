package swaycmd

import (
	"encoding/json"
	"os"

	gexec "gabyx-cli/pkg/exec"
	"gabyx-cli/pkg/interactive"
	"gabyx-cli/pkg/process"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

// swayNode is a node of the tree of `swaymsg -t get_tree`.
type swayNode struct {
	Focused       bool       `json:"focused"`
	PID           int        `json:"pid"`
	Nodes         []swayNode `json:"nodes"`
	FloatingNodes []swayNode `json:"floating_nodes"` //nolint:tagliatelle // Sway IPC key.
}

func addRunInFocusedCwdCmd(parent *cobra.Command) {
	cmd := &cobra.Command{
		Use:   "run-in-focused-cwd <command> [args...]",
		Short: "Run 'command' in the working directory of the focused window.",
		Long: `
    Changes to the working directory of the first child process of the
    focused window (e.g. the shell in a terminal) and replaces this process
    with 'command'. If no directory is found, the current directory is kept.
`,
		Args: cobra.MinimumNArgs(1),
		RunE: func(_cmd *cobra.Command, args []string) error {
			return runInFocusedCwd(args)
		},
	}

	// Flags after `command` belong to `command`.
	cmd.Flags().SetInterspersed(false)

	parent.AddCommand(cmd)
}

func runInFocusedCwd(args []string) error {
	dir, err := focusedCwd()
	if err != nil {
		log.WarnE(err, "No working directory of the focused window, keep current directory.")
	} else if e := os.Chdir(dir); e != nil {
		log.WarnE(e, "Could not change directory.", "dir", dir)
	}

	// Replace this process like `exec "$@"`.
	return interactive.Exec(nil, args...)
}

// focusedCwd returns the working directory (symlinks resolved) of the first
// child process of the focused window.
func focusedCwd() (string, error) {
	out, err := exec.NewCommandCtx(".").Get(gexec.ExtCmdSwaymsg, "-t", "get_tree", "--raw")
	if err != nil {
		return "", err
	}

	var tree swayNode

	err = json.Unmarshal([]byte(out), &tree)
	if err != nil {
		return "", errors.AddContext(err, "could not parse sway tree")
	}

	pid := focusedPID(&tree)
	if pid <= 0 {
		return "", errors.New("no focused window to get cwd from")
	}

	child, err := process.FirstChild(pid)
	if err != nil {
		return "", errors.AddContext(err, "no child process found for '%v'", pid)
	}

	// The kernel resolves symlinks in the working directory (like `cd -P`).
	return child.Cwd()
}

// focusedPID returns the PID of the focused node in the tree `n` or `0`.
func focusedPID(n *swayNode) int {
	if n.Focused {
		return n.PID
	}

	for _, nodes := range [][]swayNode{n.Nodes, n.FloatingNodes} {
		for i := range nodes {
			if pid := focusedPID(&nodes[i]); pid != 0 {
				return pid
			}
		}
	}

	return 0
}
