package waybarcmd

import (
	"github.com/spf13/cobra"
)

func addTooltipCmd(parent *cobra.Command) {
	parent.AddCommand(&cobra.Command{
		Use:   "tooltip <text>",
		Short: "Print a Waybar module output with only the tooltip 'text'.",
		Args:  cobra.ExactArgs(1),
		RunE: func(_cmd *cobra.Command, args []string) error {
			o := output{Text: "", Alt: "", Tooltip: args[0], Class: "normal", Percentage: 0}

			return o.print()
		},
	})
}
