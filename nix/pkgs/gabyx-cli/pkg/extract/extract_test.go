package extract

import (
	"archive/tar"
	"archive/zip"
	"bytes"
	"compress/gzip"
	"os"
	"path"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func writeTarGz(t *testing.T, file string, entries map[string]string) {
	t.Helper()

	var buf bytes.Buffer
	gz := gzip.NewWriter(&buf)
	tw := tar.NewWriter(gz)

	for name, content := range entries {
		require.NoError(t, tw.WriteHeader(&tar.Header{ //nolint:exhaustruct // Only the needed fields.
			Name: name, Mode: 0o644, Size: int64(len(content)), Typeflag: tar.TypeReg,
		}))
		_, err := tw.Write([]byte(content))
		require.NoError(t, err)
	}

	require.NoError(t, tw.Close())
	require.NoError(t, gz.Close())
	require.NoError(t, os.WriteFile(file, buf.Bytes(), 0o600))
}

func writeZip(t *testing.T, file string, entries map[string]string) {
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
	require.NoError(t, os.WriteFile(file, buf.Bytes(), 0o600))
}

func TestArchiveTarGzWithTopLevelDir(t *testing.T) {
	t.Parallel()
	dir := t.TempDir()

	// No file extension: the format must be detected from the content.
	archive := path.Join(dir, "archive")
	writeTarGz(t, archive, map[string]string{
		"Kit/kit.xml":         "kit",
		"Kit/samples/a.wav":   "a",
		"./Kit/samples/b.wav": "b",
	})

	partial := path.Join(dir, "out.partial")
	require.NoError(t, Archive(t.Context(), archive, partial))

	target := path.Join(dir, "drumgizmo", "kit")
	require.NoError(t, Promote(partial, target))

	// The top-level directory of the archive is kept.
	data, err := os.ReadFile(path.Join(target, "Kit", "samples", "b.wav"))
	require.NoError(t, err)
	assert.Equal(t, "b", string(data))
	assert.FileExists(t, path.Join(target, "Kit", "kit.xml"))
	assert.NoDirExists(t, partial)
}

func TestArchiveZipWithoutTopLevelDir(t *testing.T) {
	t.Parallel()
	dir := t.TempDir()

	archive := path.Join(dir, "archive")
	writeZip(t, archive, map[string]string{
		"a.sfz":         "a",
		"samples/a.wav": "a",
	})

	partial := path.Join(dir, "out.partial")
	require.NoError(t, Archive(t.Context(), archive, partial))

	target := path.Join(dir, "bass")
	require.NoError(t, Promote(partial, target))
	assert.FileExists(t, path.Join(target, "a.sfz"))
	assert.FileExists(t, path.Join(target, "samples", "a.wav"))
}

func TestArchiveRejectsPathOutsideDest(t *testing.T) {
	t.Parallel()
	dir := t.TempDir()

	archive := path.Join(dir, "archive")
	writeZip(t, archive, map[string]string{"../evil": "x"})

	err := Archive(t.Context(), archive, path.Join(dir, "out"))
	require.Error(t, err)
	assert.NoFileExists(t, path.Join(dir, "evil"))
}

func TestArchiveRejectsNonArchive(t *testing.T) {
	t.Parallel()
	dir := t.TempDir()

	archive := path.Join(dir, "archive")
	require.NoError(t, os.WriteFile(archive, []byte("<html>not an archive</html>"), 0o600))

	require.Error(t, Archive(t.Context(), archive, path.Join(dir, "out")))
}
