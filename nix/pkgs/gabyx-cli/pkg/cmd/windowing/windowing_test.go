package windowingcmd

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestFilterInputs(t *testing.T) {
	t.Parallel()

	data := []byte(`[
		{"identifier": "a", "type": "keyboard"},
		{"identifier": "b", "type": "touchpad"},
		{"identifier": "c", "type": "touchpad"}
	]`)

	res, err := filterInputs(data, "touchpad")
	require.NoError(t, err)
	require.Len(t, res, 2)
	assert.JSONEq(t, `{"identifier": "b", "type": "touchpad"}`, string(res[0]))
	assert.JSONEq(t, `{"identifier": "c", "type": "touchpad"}`, string(res[1]))

	_, err = filterInputs([]byte(`{}`), "touchpad")
	require.Error(t, err)
}
