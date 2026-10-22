package build

import (
	"fmt"

	"github.com/hashicorp/go-version"
)

// This string is set with
// `-ldflags -X "gabyx-cli/pkg/build.buildVersion=..."`.
var buildVersion = "1.0.0" //nolint:gochecknoglobals // Allowed for version.

func Version() *version.Version {
	ver, err := version.NewVersion(buildVersion)
	if err != nil {
		panic(fmt.Sprintf("Build version '%v' is invalid.", buildVersion))
	}

	return ver
}
