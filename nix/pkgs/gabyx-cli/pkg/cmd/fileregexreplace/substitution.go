package fileregexreplacecmd

import (
	"strings"
	"unicode"
	"unicode/utf8"

	"github.com/dlclark/regexp2"
	"github.com/gabyx/quitsh/pkg/errors"
)

// Substitution is a parsed Perl substitution `s<d>pattern<d>replacement<d>flags`.
type Substitution struct {
	regex       *regexp2.Regexp
	replacement string
	global      bool
}

// ParseSubstitution parses the Perl substitution expression `expr`.
// Supported flags are `g`, `s`, `m`, `i` and `x`.
func ParseSubstitution(expr string) (*Substitution, error) {
	if !strings.HasPrefix(expr, "s") || len(expr) < 2 {
		return nil, errors.New("substitution '%s' must start with 's<delimiter>'", expr)
	}

	delim, size := utf8.DecodeRuneInString(expr[1:])
	if unicode.IsLetter(delim) || unicode.IsDigit(delim) ||
		unicode.IsSpace(delim) || delim == '\\' {
		return nil, errors.New("substitution '%s' has invalid delimiter '%c'", expr, delim)
	}
	rest := expr[1+size:]

	pattern, rest, err := splitAtDelimiter(rest, delim)
	if err != nil {
		return nil, errors.AddContext(err, "could not parse pattern of '%s'", expr)
	}

	repl, flags, err := splitAtDelimiter(rest, delim)
	if err != nil {
		return nil, errors.AddContext(err, "could not parse replacement of '%s'", expr)
	}

	global := false
	opts := regexp2.RegexOptions(0)

	for _, f := range flags {
		switch f {
		case 'g':
			global = true
		case 's':
			opts |= regexp2.Singleline
		case 'm':
			opts |= regexp2.Multiline
		case 'i':
			opts |= regexp2.IgnoreCase
		case 'x':
			opts |= regexp2.IgnorePatternWhitespace
		default:
			return nil, errors.New("substitution '%s' has unsupported flag '%c'", expr, f)
		}
	}

	regex, err := regexp2.Compile(pattern, opts)
	if err != nil {
		return nil, errors.AddContext(err, "could not compile regex '%s'", pattern)
	}

	return &Substitution{
		regex:       regex,
		replacement: convertReplacement(repl),
		global:      global,
	}, nil
}

// Apply applies the substitution to `content`.
func (s *Substitution) Apply(content string) (string, error) {
	count := 1
	if s.global {
		count = -1
	}

	return s.regex.Replace(content, s.replacement, -1, count)
}

// splitAtDelimiter returns the part of `s` before the first unescaped `delim`
// and the rest after it. An escaped delimiter is unescaped.
func splitAtDelimiter(s string, delim rune) (part string, rest string, err error) {
	var b strings.Builder

	escaped := false
	for i, r := range s {
		switch {
		case escaped:
			if r != delim {
				b.WriteRune('\\')
			}
			b.WriteRune(r)
			escaped = false
		case r == '\\':
			escaped = true
		case r == delim:
			return b.String(), s[i+utf8.RuneLen(r):], nil
		default:
			b.WriteRune(r)
		}
	}

	return "", "", errors.New("missing delimiter '%c'", delim)
}

// convertReplacement converts a Perl replacement string to
// the substitution syntax of [regexp2.Regexp.Replace].
func convertReplacement(repl string) string {
	var b strings.Builder

	rs := []rune(repl)
	for i := 0; i < len(rs); i++ {
		r := rs[i]

		switch {
		case r == '\\' && i+1 < len(rs):
			i++
			switch n := rs[i]; {
			case unicode.IsDigit(n):
				b.WriteString("${")
				b.WriteRune(n)
				b.WriteString("}")
			case n == 'n':
				b.WriteRune('\n')
			case n == 't':
				b.WriteRune('\t')
			case n == 'r':
				b.WriteRune('\r')
			case n == '$':
				b.WriteString("$$")
			default:
				b.WriteRune(n)
			}
		case r == '$' && i+1 < len(rs) && unicode.IsDigit(rs[i+1]):
			j := i + 1
			for j < len(rs) && unicode.IsDigit(rs[j]) {
				j++
			}
			b.WriteString("${")
			b.WriteString(string(rs[i+1 : j]))
			b.WriteString("}")
			i = j - 1
		default:
			b.WriteRune(r)
		}
	}

	return b.String()
}
