package roficmd

import (
	"os"
	"path"
	"syscall"
	"time"

	gexec "gabyx-cli/pkg/exec"
	"gabyx-cli/pkg/process"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

const (
	recordManualArea = "Manual Area"
	recordStop       = "Stop Recording"

	// Recording timeout in seconds:
	// After 10 minutes the user has most likely forgotten the recording.
	recordTimeout = "600"
)

// recording are the files of one screen recording.
type recording struct {
	dir     string
	video   string
	palette string
	gif     string
	log     string
}

func addScreenrecordCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "screenrecord",
		Short: "Show the screen recording menu (over 'wf-recorder').",
		Long: "Show the screen recording menu (over 'wf-recorder').\n" +
			"The recording is saved as video and GIF in '~/Videos/<date>-recording'.",
		Args: cobra.NoArgs,
		RunE: runNotify("Screen recording failed.", screenrecord),
	})
}

func screenrecord() error {
	err := assertExe(
		gexec.ExtCmdRofi,
		gexec.ExtCmdSlurp,
		gexec.ExtCmdWfRecorder,
		gexec.ExtCmdFfmpeg,
		gexec.ExtCmdTimeout,
	)
	if err != nil {
		return err
	}

	choice, ok, err := menu("Screen Record", []string{recordManualArea, recordStop})
	if err != nil || !ok {
		return err
	}

	switch choice {
	case recordManualArea:
		home, e := os.UserHomeDir()
		if e != nil {
			return e
		}

		return recordManual(newRecording(path.Join(home, "Videos"), time.Now()))
	case recordStop:
		return stopRecorder()
	}

	return nil
}

// newRecording returns the files of the recording in `dir` for time `t`.
func newRecording(dir string, t time.Time) recording {
	d := path.Join(dir, t.Format(fileTimeFormat)+"-recording")

	return recording{
		dir:     d,
		video:   path.Join(d, "recording.mp4"),
		palette: path.Join(d, "palette.png"),
		gif:     path.Join(d, "palette.gif"),
		log:     path.Join(d, "log.txt"),
	}
}

// recordManual records a manually selected screen area into `rec.video`
// and converts it to `rec.gif`. The output of all commands is written to `rec.log`.
func recordManual(rec recording) error {
	err := os.MkdirAll(rec.dir, 0o755)
	if err != nil {
		return err
	}

	logFile, err := os.Create(rec.log)
	if err != nil {
		return err
	}
	defer logFile.Close()

	// The command contexts pipe to `os.Stdout` and `os.Stderr`.
	stdout, stderr := os.Stdout, os.Stderr
	os.Stdout, os.Stderr = logFile, logFile
	defer func() { os.Stdout, os.Stderr = stdout, stderr }()

	defer func() { _ = os.Remove(rec.palette) }()

	cmdx := exec.NewCommandCtx(".")

	coords, err := cmdx.Get(gexec.ExtCmdSlurp)
	if err != nil {
		return cancelRecording(rec, "Cancelled screen selection.")
	}

	notify("Start recording.", "File '"+rec.video+"'.")

	err = cmdx.Check(gexec.ExtCmdTimeout, recordTimeout, gexec.ExtCmdWfRecorder, "-g", coords, "-f", rec.video)
	if err != nil {
		return cancelRecording(rec, "Cancelled screen recording.", "-> timeout!")
	}

	notify("Recording saved.", "File '"+rec.video+"'.")

	err = cmdx.Check(gexec.ExtCmdFfmpeg, "-i", rec.video,
		"-filter_complex", "palettegen=stats_mode=full",
		rec.palette, "-y")
	if err != nil {
		return errors.AddContext(err, "computing palette from recording failed")
	}

	err = cmdx.Check(gexec.ExtCmdFfmpeg, "-i", rec.video, "-i", rec.palette,
		"-filter_complex", "paletteuse=dither=sierra2_4a",
		rec.gif, "-y")
	if err != nil {
		return errors.AddContext(err, "computing GIF from recording failed")
	}

	return nil
}

// cancelRecording sends the warning notification `summary` and `body`
// and removes the recording directory.
func cancelRecording(rec recording, summary string, body ...string) error {
	notifyError(summary, body...)

	return os.RemoveAll(rec.dir)
}

// stopRecorder stops all running `wf-recorder` processes of the current user.
func stopRecorder() error {
	count, err := process.Signal(gexec.ExtCmdWfRecorder, os.Getuid(), syscall.SIGINT)
	if err != nil || count == 0 {
		notifyError("Could not stop wf-recorder.", "Is it running?")
	}

	return nil
}
