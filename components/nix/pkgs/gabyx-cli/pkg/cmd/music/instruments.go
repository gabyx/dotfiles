package musiccmd

import (
	"context"
	"os"
	"path"
	"strings"

	"gabyx-cli/pkg/download"
	"gabyx-cli/pkg/extract"

	"github.com/gabyx/quitsh/pkg/errors"
	fs "github.com/gabyx/quitsh/pkg/filesystem"
	"github.com/gabyx/quitsh/pkg/log"
)

// Directory (relative to the instruments dataset) where downloaded archives are kept.
const archiveDir = ".archive"

//nolint:gochecknoglobals // Allowed for constant definitions.
var instruments = []instrument{
	{
		dir: "drumgizmo/aasimonster",
		url: "https://drumgizmo.org/kits/Aasimonster/aasimonster2_1.zip",
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
		url: "https://archive.org/download/httpswww.ir.isas.jaxa.jpcyamauchaccuratesalamander/MoonlightSalamanderGrandPianoV6.2a_48khz24bit_flac.zip",
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
// if that directory does not exist.
// The archive is kept in `root/.archive/` and only downloaded if it is not there.
// The archive is extracted into `<dir>.partial` and renamed to `<dir>` when complete,
// so `<dir>` only exists after a complete extraction.
func installInstrument(ctx context.Context, root string, inst instrument) (err error) {
	target := path.Join(root, inst.dir)
	if fs.Exists(target) {
		log.Info("Instrument present, skip.", "dir", target)

		return extract.FlattenSingleDirs(target)
	}

	// The download is renamed to `archive` only when complete,
	// an existing `archive` is a complete download.
	archive := path.Join(root, archiveDir, strings.ReplaceAll(inst.dir, "/", "-"))
	contentType := "unknown"

	if fs.Exists(archive) {
		log.Info("Archive present, skip download.", "archive", archive)
	} else {
		contentType, err = download.File(ctx, inst.url, archive)
		if err != nil {
			return err
		}
	}

	log.Info("Extracting.", "archive", archive, "dir", target)
	err = extract.Archive(ctx, archive, target)
	if err != nil {
		_ = os.RemoveAll(target)

		return errors.AddContext(err,
			"content type of '%s' was '%s', remove '%s' to download it again",
			inst.url, contentType, target)
	}

	return nil
}
