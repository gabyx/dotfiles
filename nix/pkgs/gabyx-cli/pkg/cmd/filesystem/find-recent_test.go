package filesystemcmd

import (
	"os"
	"path"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestFindRecent(t *testing.T) {
	t.Parallel()

	dir := t.TempDir()
	now := time.Now()

	create := func(name string, age time.Duration) string {
		p := path.Join(dir, name)
		require.NoError(t, os.MkdirAll(path.Dir(p), 0o755))
		require.NoError(t, os.WriteFile(p, nil, 0o600))
		require.NoError(t, os.Chtimes(p, now.Add(-age), now.Add(-age)))

		return p
	}

	a := create("tmux_a.txt", 3*time.Hour)
	b := create("sub/tmux_b.txt", 1*time.Hour)
	c := create("tmux_c.txt", 2*time.Hour)
	o := create("other.txt", 0)
	create(".git/tmux_d.txt", 0)

	paths := func(globs ...string) []string {
		files, err := FindRecent(dir, globs...)
		require.NoError(t, err)

		res := make([]string, 0, len(files))
		for _, f := range files {
			res = append(res, f.Path)
		}

		return res
	}

	assert.Equal(t, []string{a, c}, paths("tmux_*"))
	assert.Equal(t, []string{a, c, b}, paths("**/tmux_*"))
	assert.Equal(t, []string{a, c, b, o}, paths())
}
