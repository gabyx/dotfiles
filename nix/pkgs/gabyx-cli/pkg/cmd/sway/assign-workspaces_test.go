package swaycmd

import (
	"testing"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const testConfig = `
set $ws-1 1:1: A
set $primaryDispHome 'Philips PHL 275E2F UHB1'
set $secondaryDispHome 'Dell Inc. DELL U2724DE 4TP'
set $primaryDispWork 'Dell Inc. DELL U3421WE B6V'
set $secondaryDispWork 'Dell Inc. DELL U3421WE B6V'
`

const testConfigWorkspaces = `# Assign to first monitor.
workspace $ws-1 output $primaryDisp
workspace $ws-2 output $primaryDisp

# Assign the special workspaces to second monitor.
workspace $ws-comm  output $secondaryDisp
workspace $ws-mail  output $secondaryDisp
workspace "Empty" output eDP-1
`

func TestDetectDisplaysHome(t *testing.T) {
	t.Parallel()

	outputs := []swayOutput{
		{Name: "DP-1", Make: "Philips", Model: "PHL 275E2F", Serial: "UHB1"},
		{Name: "DP-2", Make: "Dell Inc.", Model: "DELL U2724DE", Serial: "4TP"},
	}

	r := report{lines: nil}
	disp, err := detectDisplays(&r, testConfig, outputs)
	require.NoError(t, err)
	assert.Equal(t, "Philips PHL 275E2F UHB1", disp.primary)
	assert.Equal(t, "Dell Inc. DELL U2724DE 4TP", disp.secondary)
}

func TestDetectDisplaysWorkSameDisplay(t *testing.T) {
	t.Parallel()

	outputs := []swayOutput{
		{Name: "DP-3", Make: "Dell Inc.", Model: "DELL U3421WE", Serial: "B6V"},
	}

	r := report{lines: nil}
	disp, err := detectDisplays(&r, testConfig, outputs)
	require.NoError(t, err)
	assert.Equal(t, "Dell Inc. DELL U3421WE B6V", disp.primary)
	assert.Equal(t, "Dell Inc. DELL U3421WE B6V", disp.secondary)
	assert.Contains(t, r.String(), "No primary monitor for 'Home' found.")
}

func TestDetectDisplaysExternal(t *testing.T) {
	t.Parallel()

	r := report{lines: nil}

	disp, err := detectDisplays(&r, testConfig, []swayOutput{{Name: "DP-1", Make: "", Model: "", Serial: ""}})
	require.NoError(t, err)
	assert.Equal(t, "DP-1", disp.primary)
	assert.Equal(t, "DP-1", disp.secondary)

	_, err = detectDisplays(&r, testConfig, []swayOutput{{Name: "eDP-1", Make: "", Model: "", Serial: ""}})
	require.Error(t, err)
}

func TestWorkspaceAssignments(t *testing.T) {
	t.Parallel()

	primary, secondary := workspaceAssignments(testConfigWorkspaces)
	assert.Equal(t, []string{"$ws-1", "$ws-2"}, primary)
	assert.Equal(t, []string{"$ws-comm", "$ws-mail"}, secondary)
}

func TestStripComments(t *testing.T) {
	t.Parallel()

	assert.Equal(t, "\na\n  # b", stripComments("# c\na\n  # b"))
}

func TestNotifyArgs(t *testing.T) {
	t.Parallel()

	assert.Equal(t,
		[]string{"Assign workspaces to outputs.", "Workspaces moved:\nok"},
		notifyArgs("ok", nil))

	assert.Equal(t,
		[]string{"-u", "normal", "Assign workspaces to outputs.", "Workspaces not moved:\nmsg\nfail"},
		notifyArgs("msg", errors.New("fail")))
}
