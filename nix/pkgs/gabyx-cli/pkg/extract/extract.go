package extract

import (
	"context"
	"io"
	"io/fs"
	"os"
	"path"
	"path/filepath"
	"strings"

	"github.com/gabyx/quitsh/pkg/errors"
	qfs "github.com/gabyx/quitsh/pkg/filesystem"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/mholt/archives"
)

// Directories created by macOS archivers which are not extracted.
const macOSMetadataDir = "__MACOSX"

// Archive extracts the archive file `archive` into the directory `destDir`.
// The format (zip, tar, tar.gz, tar.xz, 7z, ...) is detected from the file
// content, not from the file name.
// Entries with absolute paths or paths leaving `destDir` (`..`) are rejected.
func Archive(ctx context.Context, archive string, destDir string) error {
	f, err := os.Open(archive)
	if err != nil {
		return err
	}
	defer f.Close()

	// No file name is given: the format is only matched by the content.
	format, stream, err := archives.Identify(ctx, "", f)
	if err != nil {
		return errors.AddContext(err, "could not detect archive format of '%s'", archive)
	}

	extractor, ok := format.(archives.Extractor)
	if !ok {
		return errors.New("format '%s' of '%s' is not an archive", format.MediaType(), archive)
	}

	err = os.MkdirAll(destDir, qfs.DefaultPermissionsDir)
	if err != nil {
		return err
	}

	err = extractor.Extract(ctx, stream, func(_ctx context.Context, file archives.FileInfo) error {
		return extractFile(destDir, file)
	})
	if err != nil {
		return errors.AddContext(err, "could not extract '%s'", archive)
	}

	return nil
}

func extractFile(destDir string, file archives.FileInfo) error {
	name, skip, err := localName(file.NameInArchive)
	if err != nil || skip {
		return err
	}

	dest := filepath.Join(destDir, name)
	mode := file.Mode()

	switch {
	case file.IsDir():
		return os.MkdirAll(dest, qfs.DefaultPermissionsDir)

	case mode&fs.ModeSymlink != 0:
		target := filepath.Join(filepath.Dir(name), filepath.FromSlash(file.LinkTarget))
		if filepath.IsAbs(file.LinkTarget) || !filepath.IsLocal(target) {
			return errors.New("symlink '%s' -> '%s' points outside the destination",
				file.NameInArchive, file.LinkTarget)
		}

		err = os.MkdirAll(filepath.Dir(dest), qfs.DefaultPermissionsDir)
		if err != nil {
			return err
		}

		return os.Symlink(file.LinkTarget, dest)

	case mode.IsRegular():
		return writeFile(dest, file)

	default:
		log.Warn("Skip unsupported archive entry.", "entry", file.NameInArchive, "mode", mode.String())

		return nil
	}
}

// localName returns the cleaned relative path of an archive entry.
// It returns an error for entries which would be written outside the destination
// and `skip == true` for entries which are not extracted.
func localName(nameInArchive string) (name string, skip bool, err error) {
	name = path.Clean(strings.TrimPrefix(nameInArchive, "./"))
	if name == "." || name == macOSMetadataDir || strings.HasPrefix(name, macOSMetadataDir+"/") {
		return "", true, nil
	}

	name = filepath.FromSlash(name)
	if !filepath.IsLocal(name) {
		return "", false, errors.New("archive entry '%s' points outside the destination", nameInArchive)
	}

	return name, false, nil
}

func writeFile(dest string, file archives.FileInfo) error {
	err := os.MkdirAll(filepath.Dir(dest), qfs.DefaultPermissionsDir)
	if err != nil {
		return err
	}

	src, err := file.Open()
	if err != nil {
		return err
	}
	defer src.Close()

	// The owner always gets read and write access, some archives store `0` permissions.
	perm := file.Mode().Perm() | 0o600 //nolint:mnd // Owner read/write.

	out, err := os.OpenFile(dest, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, perm)
	if err != nil {
		return err
	}

	_, err = io.Copy(out, src)

	return errors.Combine(err, out.Close())
}

// Promote moves the extracted directory `extracted` to `target`.
// If `extracted` contains only a single directory (the usual top-level
// directory of an archive), that directory is moved to `target` instead.
// The parent directories of `target` are created.
func Promote(extracted string, target string) error {
	entries, err := os.ReadDir(extracted)
	if err != nil {
		return err
	}

	err = os.MkdirAll(filepath.Dir(target), qfs.DefaultPermissionsDir)
	if err != nil {
		return err
	}

	if len(entries) != 1 || !entries[0].IsDir() {
		return os.Rename(extracted, target)
	}

	err = os.Rename(filepath.Join(extracted, entries[0].Name()), target)
	if err != nil {
		return err
	}

	return os.Remove(extracted)
}
