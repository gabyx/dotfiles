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

// Archive extracts the archive file `archive` into the directory `destDir`.
// The format (zip, tar, tar.gz, tar.xz, 7z, ...) is detected from the file
// content, not from the file name.
// Entries with absolute paths or paths leaving `destDir` (`..`) are rejected.
func Archive(ctx context.Context, archive string, destDir string) error {
	f, err := os.Open(archive)
	if err != nil {
		return err
	}
	defer func() { _ = f.Close() }()

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

	return FlattenSingleDirs(destDir)
}

func FlattenSingleDirs(destDir string) error {
	deepestDir := destDir
	entries, err := os.ReadDir(deepestDir)
	if err != nil {
		return err
	}

	for {
		if len(entries) != 1 {
			break
		}
		p := path.Join(deepestDir, entries[0].Name())

		stat, err := os.Stat(p)
		if err != nil {
			return err
		}

		if !stat.IsDir() {
			break
		}

		// Go to next folder.
		deepestDir = path.Join(deepestDir, entries[0].Name())
		entries, err = os.ReadDir(deepestDir)
		if err != nil {
			return err
		}
	}

	if deepestDir == destDir {
		log.Infof("Directory '%v' already flattened.", destDir)

		return nil
	}

	log.Infof("Flatten directory '%v' to '%v'.", deepestDir, destDir)
	newP := path.Join(destDir + ".temp")
	err = os.Rename(deepestDir, newP)
	if err != nil {
		return err
	}

	err = os.RemoveAll(destDir)
	if err != nil {
		return err
	}

	return os.Rename(newP, destDir)
}

func extractFile(destDir string, file archives.FileInfo) error {
	name, skip, err := localName(file.NameInArchive)
	if err != nil || skip {
		return err
	}

	dest := path.Join(destDir, name)
	mode := file.Mode()

	switch {
	case file.IsDir():
		return os.MkdirAll(dest, qfs.DefaultPermissionsDir)

	case mode&fs.ModeSymlink != 0:
		target := path.Join(path.Dir(name), file.LinkTarget)
		if path.IsAbs(file.LinkTarget) || !filepath.IsLocal(target) {
			return errors.New("symlink '%s' -> '%s' points outside the destination",
				file.NameInArchive, file.LinkTarget)
		}

		err = os.MkdirAll(path.Dir(dest), qfs.DefaultPermissionsDir)
		if err != nil {
			return err
		}

		return os.Symlink(file.LinkTarget, dest)

	case mode.IsRegular():
		return writeFile(dest, file)

	default:
		log.Warn(
			"Skip unsupported archive entry.",
			"entry",
			file.NameInArchive,
			"mode",
			mode.String(),
		)

		return nil
	}
}

// localName returns the cleaned relative path of an archive entry.
// It returns an error for entries which would be written outside the destination
// and `skip == true` for the root entry `.`.
func localName(nameInArchive string) (name string, skip bool, err error) {
	name = path.Clean(strings.TrimPrefix(nameInArchive, "./"))
	if name == "." {
		return "", true, nil
	}

	if !filepath.IsLocal(name) {
		return "", false, errors.New(
			"archive entry '%s' points outside the destination",
			nameInArchive,
		)
	}

	return name, false, nil
}

func writeFile(dest string, file archives.FileInfo) error {
	err := os.MkdirAll(path.Dir(dest), qfs.DefaultPermissionsDir)
	if err != nil {
		return err
	}

	src, err := file.Open()
	if err != nil {
		return err
	}
	defer func() { _ = src.Close() }()

	// The owner always gets read and write access, some archives store `0` permissions.
	perm := file.Mode().Perm() | 0o600 //nolint:mnd // Owner read/write.

	out, err := os.OpenFile(dest, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, perm)
	if err != nil {
		return err
	}

	_, err = io.Copy(out, src)

	return errors.Combine(err, out.Close())
}
