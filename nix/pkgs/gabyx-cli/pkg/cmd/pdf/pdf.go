package pdfcmd

import (
	"slices"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/spf13/cobra"
)

//nolint:gochecknoglobals // Allowed for constant definitions.
var levels = []string{"screen", "ebook", "prepress", "default"}

func AddCmd(root *cobra.Command) {
	pdfCmd := &cobra.Command{
		Use:   "pdf",
		Short: "PDF commands.",
	}

	compressCmd := &cobra.Command{
		Use:       "compress <file> <output> [screen|ebook|prepress|default]",
		Short:     "Compress a PDF with Ghostscript (default level: 'screen').",
		Args:      cobra.RangeArgs(2, 3), //nolint:mnd
		ValidArgs: levels,
		RunE: func(_cmd *cobra.Command, args []string) error {
			level := "screen"
			if len(args) > 2 { //nolint:mnd
				level = args[2]
			}

			return compress(args[0], args[1], level)
		},
	}

	pdfCmd.AddCommand(compressCmd)
	root.AddCommand(pdfCmd)
}

func compress(file string, output string, level string) error {
	if !slices.Contains(levels, level) {
		return errors.New("the level '%s' must be one of '%v'", level, levels)
	}

	return exec.NewCommandCtx(".").
		Check("gs",
			"-sDEVICE=pdfwrite",
			"-dCompatibilityLevel=1.4",
			"-dPDFSETTINGS=/"+level,
			"-dNOPAUSE",
			"-dBATCH",
			"-sOutputFile="+output,
			file)
}
