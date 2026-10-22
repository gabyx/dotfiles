package fileregexreplacecmd

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestSubstitution(t *testing.T) {
	t.Parallel()

	tests := []struct {
		expr   string
		input  string
		output string
	}{
		{expr: "s@foo@bar@", input: "foo foo", output: "bar foo"},
		{expr: "s@foo@bar@g", input: "foo foo", output: "bar bar"},
		{expr: "s/a\\/b/c/g", input: "a/b a/b", output: "c c"},
		{expr: "s@(\\w+)-(\\w+)@$2-$1@g", input: "a-b c-d", output: "b-a d-c"},
		{expr: "s@(\\w+)-(\\w+)@\\2-\\1@", input: "a-b", output: "b-a"},
		{expr: "s@(\\d)@${1}0@g", input: "1 2", output: "10 20"},
		{expr: "s@a.b@X@s", input: "a\nb", output: "X"},
		{expr: "s@a.b@X@", input: "a\nb\n", output: "a\nb\n"},
		{expr: "s@^b@X@mg", input: "a\nb\nb", output: "a\nX\nX"},
		{expr: "s@FOO@x@i", input: "foo", output: "x"},
		{expr: "s@(?<=a)b@X@g", input: "ab cb", output: "aX cb"},
		{expr: "s@a@\\$1\\n@", input: "a", output: "$1\n"},
		{expr: "s@.*@Gaga@s", input: "multi\nline\n", output: "Gaga"},
	}

	for _, tt := range tests {
		s, err := ParseSubstitution(tt.expr)
		require.NoError(t, err, tt.expr)

		out, err := s.Apply(tt.input)
		require.NoError(t, err, tt.expr)
		assert.Equal(t, tt.output, out, tt.expr)
	}
}

func TestSubstitutionInvalid(t *testing.T) {
	t.Parallel()

	for _, expr := range []string{"s@a@b", "s@a@b@e", "x@a@b@", "sxaxbx"} {
		_, err := ParseSubstitution(expr)
		require.Error(t, err, expr)
	}
}
