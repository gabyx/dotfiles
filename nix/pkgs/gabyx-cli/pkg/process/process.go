// Package process finds and signals processes (over `gopsutil`).
package process

import (
	"cmp"
	"slices"
	"syscall"

	"github.com/gabyx/quitsh/pkg/errors"
	ps "github.com/shirou/gopsutil/v4/process"
)

// Signal sends the signal `sig` to all processes with the name `name` and the
// effective user ID `euid`, like `pkill --euid <euid> --signal <sig> <name>`.
// The name on Linux is the one in `/proc/<pid>/status`, which the kernel
// truncates to 15 characters. It returns the number of signaled processes.
func Signal(name string, euid int, sig syscall.Signal) (count int, err error) {
	procs, err := ps.Processes()
	if err != nil {
		return 0, err
	}

	for _, p := range procs {
		// Errors mean the process has exited in the meantime.
		n, e := p.Name()
		if e != nil || n != name {
			continue
		}

		uids, e := p.Uids() // Real, effective, saved and filesystem user ID.
		if e != nil || len(uids) < 2 || int(uids[1]) != euid {
			continue
		}

		e = p.SendSignal(sig)
		if e != nil {
			err = errors.Combine(err, errors.AddContext(e, "could not signal process '%v'", p.Pid))

			continue
		}

		count++
	}

	return count, err
}

// FirstChild returns the child process with the lowest PID
// of the process `pid`, like `pgrep -P <pid> | head -n 1`.
func FirstChild(pid int) (*ps.Process, error) {
	p, err := ps.NewProcess(int32(pid)) //nolint:gosec // PIDs fit into 32 bits.
	if err != nil {
		return nil, err
	}

	children, err := p.Children()
	if err != nil {
		return nil, err
	} else if len(children) == 0 {
		return nil, errors.New("process '%v' has no child process", pid)
	}

	return slices.MinFunc(children, func(a, b *ps.Process) int {
		return cmp.Compare(a.Pid, b.Pid)
	}), nil
}
