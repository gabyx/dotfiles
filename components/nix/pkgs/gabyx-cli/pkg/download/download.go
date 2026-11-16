package download

import (
	"context"
	"io"
	"net/http"
	"os"
	"path"
	"time"

	"charm.land/bubbles/v2/progress"
	tea "charm.land/bubbletea/v2"
	"github.com/charmbracelet/x/term"
	"github.com/dustin/go-humanize"
	"github.com/gabyx/quitsh/pkg/errors"
	qfs "github.com/gabyx/quitsh/pkg/filesystem"
	"github.com/gabyx/quitsh/pkg/log"
)

const (
	// Minimal time between two progress updates.
	reportInterval = 100 * time.Millisecond
	// Width of the progress bar in characters.
	barWidth = 40
)

type reportWriter struct {
	written    int64
	lastReport time.Time
	report     func(written int64)
}

type progressMsg int64

type doneMsg struct{}

type model struct {
	title   string
	total   int64
	written int64
	bar     progress.Model
}

// File downloads `url` to the file `dest`.
// A progress bar is shown on stderr if stderr is a terminal.
// The data is written to `<dest>.part` and renamed to `dest` when complete.
// It returns the `Content-Type` header of the response.
func File(ctx context.Context, url string, dest string) (contentType string, err error) {
	if qfs.Exists(dest) {
		return "", errors.New("file exists '%s'", dest)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return "", err
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", errors.AddContext(err, "could not download '%s'", url)
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode != http.StatusOK {
		return "", errors.New("could not download '%s': status '%s'", url, resp.Status)
	}

	contentType = resp.Header.Get("Content-Type")
	total := resp.ContentLength // `-1` if unknown.

	err = os.MkdirAll(path.Dir(dest), qfs.DefaultPermissionsDir)
	if err != nil {
		return contentType, err
	}

	log.Info("Downloading.", "url", url, "size", sizeString(total), "content-type", contentType)

	part := dest + ".part"
	if term.IsTerminal(os.Stderr.Fd()) {
		err = copyWithProgress(ctx, path.Base(dest), total, resp.Body, part)
	} else {
		err = copyToFile(resp.Body, part, func(int64) {})
	}

	if err != nil {
		_ = os.Remove(part)

		return contentType, errors.AddContext(err, "could not download '%s'", url)
	}

	return contentType, os.Rename(part, dest)
}

// copyWithProgress copies `src` to the file `dest` and renders a progress bar
// on stderr while copying.
func copyWithProgress(
	ctx context.Context,
	title string,
	total int64,
	src io.Reader,
	dest string,
) error {
	p := tea.NewProgram(newModel(title, total),
		tea.WithContext(ctx),
		tea.WithInput(nil),
		tea.WithOutput(os.Stderr),
		// Signals are handled by the CLI context `ctx`.
		tea.WithoutSignalHandler())

	errCh := make(chan error, 1)
	go func() {
		e := copyToFile(src, dest, func(written int64) {
			p.Send(progressMsg(written))
		})
		p.Send(doneMsg{})
		errCh <- e
	}()

	_, errUI := p.Run()
	// The copy stops on its own when `ctx` is canceled (request context).
	err := <-errCh
	if err != nil {
		return err
	}

	if errUI != nil {
		log.WarnE(errUI, "Progress bar failed.")
	}

	return nil
}

// copyToFile copies `src` to the file `dest` and calls `report`
// with the number of written bytes at most every `reportInterval`
// and once at the end.
func copyToFile(src io.Reader, dest string, report func(written int64)) error {
	out, err := os.Create(dest)
	if err != nil {
		return err
	}

	w := &reportWriter{written: 0, lastReport: time.Time{}, report: report}
	_, err = io.Copy(io.MultiWriter(out, w), src)
	report(w.written)

	return errors.Combine(err, out.Close())
}

func (w *reportWriter) Write(p []byte) (int, error) {
	w.written += int64(len(p))

	if now := time.Now(); now.Sub(w.lastReport) >= reportInterval {
		w.lastReport = now
		w.report(w.written)
	}

	return len(p), nil
}

func sizeString(size int64) string {
	if size < 0 {
		return "unknown"
	}

	return humanize.IBytes(uint64(size))
}

func newModel(title string, total int64) model {
	return model{
		title:   title,
		total:   total,
		written: 0,
		bar:     progress.New(progress.WithDefaultBlend(), progress.WithWidth(barWidth)),
	}
}

func (m model) Init() tea.Cmd {
	return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case progressMsg:
		m.written = int64(msg)
	case doneMsg:
		return m, tea.Quit
	}

	return m, nil
}

func (m model) View() tea.View {
	written := sizeString(m.written)

	if m.total <= 0 {
		// Size unknown: only show the downloaded bytes.
		return tea.NewView(m.title + "  " + written + "\n")
	}

	percent := float64(m.written) / float64(m.total)

	return tea.NewView(m.title + "\n" +
		m.bar.ViewAs(percent) + "  " + written + " / " + sizeString(m.total) + "\n")
}
