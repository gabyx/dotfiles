package musiccmd

import (
	"archive/zip"
	"bytes"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"sync/atomic"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func zipBytes(t *testing.T, entries map[string]string) []byte {
	t.Helper()

	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	for name, content := range entries {
		w, err := zw.Create(name)
		require.NoError(t, err)
		_, err = w.Write([]byte(content))
		require.NoError(t, err)
	}
	require.NoError(t, zw.Close())

	return buf.Bytes()
}

func TestInstallInstrumentSkipsPresent(t *testing.T) {
	t.Parallel()

	data := zipBytes(t, map[string]string{"Kit/kit.xml": "kit"})

	var requests atomic.Int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		requests.Add(1)
		_, _ = w.Write(data)
	}))
	defer srv.Close()

	root := t.TempDir()
	inst := instrument{dir: "drumgizmo/kit", url: srv.URL}

	require.NoError(t, installInstrument(t.Context(), root, inst))
	assert.FileExists(t, filepath.Join(root, "drumgizmo", "kit", "kit.xml"))
	assert.NoDirExists(t, filepath.Join(root, "drumgizmo", "kit.partial"))
	assert.NoFileExists(t, filepath.Join(root, downloadDir, "drumgizmo-kit"))

	// Second run: the directory is present, nothing is downloaded.
	require.NoError(t, installInstrument(t.Context(), root, inst))
	assert.Equal(t, int32(1), requests.Load())
}

func TestInstallInstrumentReplacesPartial(t *testing.T) {
	t.Parallel()

	data := zipBytes(t, map[string]string{"a.sfz": "a"})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write(data)
	}))
	defer srv.Close()

	root := t.TempDir()
	inst := instrument{dir: "sfizz/a", url: srv.URL}

	// Leftover of an interrupted run.
	partial := filepath.Join(root, "sfizz", "a.partial")
	require.NoError(t, os.MkdirAll(partial, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(partial, "stale"), nil, 0o600))

	require.NoError(t, installInstrument(t.Context(), root, inst))
	assert.FileExists(t, filepath.Join(root, "sfizz", "a", "a.sfz"))
	assert.NoFileExists(t, filepath.Join(root, "sfizz", "a", "stale"))
	assert.NoDirExists(t, partial)
}

func TestInstallInstrumentsContinuesOnError(t *testing.T) {
	t.Parallel()

	data := zipBytes(t, map[string]string{"a.sfz": "a"})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/missing" {
			http.NotFound(w, r)

			return
		}
		_, _ = w.Write(data)
	}))
	defer srv.Close()

	root := t.TempDir()
	err := installInstruments(t.Context(), root, []instrument{
		{dir: "missing", url: srv.URL + "/missing"},
		{dir: "present", url: srv.URL + "/present"},
	})

	require.Error(t, err)
	assert.NoDirExists(t, filepath.Join(root, "missing"))
	assert.FileExists(t, filepath.Join(root, "present", "a.sfz"))
}
