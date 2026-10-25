package musiccmd

import (
	"context"
	"os"
	"path/filepath"
	"strings"

	"gabyx-cli/pkg/download"
	"gabyx-cli/pkg/extract"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/log"
)

// Directory (relative to the instruments dataset) for downloaded archives.
const downloadDir = ".download"

//nolint:gochecknoglobals // Allowed for constant definitions.
var instruments = []instrument{
	{
		dir: "drumgizmo/aasimonster2",
		url: "https://www.drumgizmo.org/kits/Aasimonster/DrumGizmo-Aasimonster.tar.gz",
	},
	{
		dir: "drumgizmo/crocellkit",
		url: "https://drumgizmo.org/kits/CrocellKit/CrocellKit1_1.zip",
	},
	{
		dir: "drumgizmo/drskit",
		url: "https://drumgizmo.org/kits/DRSKit/DRSKit2_1.zip",
	},
	{
		dir: "sfizz/bass/bass-black-and-blue",
		url: "https://github.com/sfzinstruments/karoryfer.black-and-blue-basses/" +
			"releases/download/v1.002/Black_And_Blue_Basses_1002.zip",
	},
	{
		dir: "sfizz/piano/piano-moonlight-salamander",
		url: "https://kamo.teracloud.jp/v2/api/share/public/12917a5a1e8eb4b6/6adb204a45ae",
	},
	{
		dir: "mt-powerdrumkit/drummap",
		url: "https://resources.manda-audio.com/DOWNLOADS/presets/drum-maps/" +
			"MT-PowerDrumKit_2_Drum_Map_for_Ardour.zip",
	},
}

type instrument struct {
	// Directory relative to the instruments dataset.
	dir string
	// URL of the archive (format detected from the content).
	url string
}

// installInstruments downloads and extracts all instruments `insts` into `root`
// which are not yet present. Failing instruments do not stop the others.
func installInstruments(ctx context.Context, root string, insts []instrument) (err error) {
	for _, inst := range insts {
		if e := ctx.Err(); e != nil {
			return errors.Combine(err, e)
		}

		e := installInstrument(ctx, root, inst)
		if e != nil {
			log.ErrorE(e, "Could not install instrument.", "instrument", inst.dir)
			err = errors.Combine(err, e)
		}
	}

	return err
}

// installInstrument downloads and extracts the instrument `inst` into `root/inst.dir`,
// if that directory does not exist or is empty.
// The archive is extracted into `<dir>.partial` and renamed to `<dir>` when complete,
// so `<dir>` only exists after a complete extraction.
func installInstrument(ctx context.Context, root string, inst instrument) error {
	target := filepath.Join(root, inst.dir)
	if isInstalled(target) {
		log.Info("Instrument present, skip.", "dir", target)

		return nil
	}

	partial := target + ".partial"
	err := os.RemoveAll(partial)
	if err != nil {
		return err
	}

	archive := filepath.Join(root, downloadDir, strings.ReplaceAll(inst.dir, "/", "-"))
	contentType, err := download.File(ctx, inst.url, archive)
	if err != nil {
		return err
	}
	defer os.Remove(archive)

	log.Info("Extracting.", "archive", archive, "dir", target)

	err = extract.Archive(ctx, archive, partial)
	if err != nil {
		_ = os.RemoveAll(partial)

		return errors.AddContext(err, "content type of '%s' was '%s'", inst.url, contentType)
	}

	return extract.Promote(partial, target)
}

// isInstalled returns `true` if `dir` is a non-empty directory.
func isInstalled(dir string) bool {
	entries, err := os.ReadDir(dir)

	return err == nil && len(entries) > 0
}
