package nixoscmd

import (
	"os"
	"path/filepath"
	"strings"

	gexec "gabyx-cli/pkg/exec"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	fs "github.com/gabyx/quitsh/pkg/filesystem"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

const longDescConfigSetup = `
    Setup the chezmoi repository in '--dest' (default: '~/.local/share/chezmoi')
    from the Nix store path '--store' and apply the chezmoi config files.
    If '--dest' does not exist, a temporary Git repo with remote '--url' is
    created, the store content is committed and 'chezmoi init' is run for
    '--workspace'.
    The config files are applied from a temporary copy of '--dest' in which all
    secrets (targets of '*.age' symlinks) are replaced by dummy files.
    Encrypted files are not applied.
    If the environment variable 'DRY_RUN' is set, nothing is done.
`

type configSetupArgs struct {
	url       string
	ref       string
	workspace string
	store     string
	dest      string
	force     bool
}

func addConfigSetupCmd(parent *cobra.Command) {
	var args configSetupArgs

	cmd := &cobra.Command{
		Use:   "config-setup",
		Short: "Setup the chezmoi repository and apply the chezmoi config files.",
		Long:  longDescConfigSetup,
		Args:  cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			if args.dest == "" {
				home, err := os.UserHomeDir()
				if err != nil {
					return err
				}
				args.dest = filepath.Join(home, ".local/share/chezmoi")
			}

			return configSetup(&args)
		},
	}

	f := cmd.Flags()
	f.StringVar(&args.url, "url", "", "The Git URL set as remote 'origin' of 'dest'.")
	f.StringVar(&args.ref, "ref", "", "The Git ref of the chezmoi repository.")
	f.StringVar(&args.workspace, "workspace", "",
		"The chezmoi 'workspace' setting in '.chezmoi.yaml.tmpl' [private|work].")
	f.StringVar(&args.store, "store", "", "The Nix store path to setup the initial Git repo from.")
	f.StringVar(&args.dest, "dest", "",
		"The chezmoi source directory (default: '~/.local/share/chezmoi').")
	f.BoolVarP(&args.force,
		"force", "f", false, "Remove 'dest' and the chezmoi config and setup again.")

	for _, n := range []string{"url", "ref", "workspace"} {
		_ = cmd.MarkFlagRequired(n)
	}

	parent.AddCommand(cmd)
}

func configSetup(args *configSetupArgs) error {
	if os.Getenv("DRY_RUN") != "" {
		log.Info("Dry-run: No chezmoi install.")

		return nil
	}

	if args.force && fs.Exists(args.dest) {
		clean(args.dest)
	}

	err := initRepo(args)
	if err != nil {
		return err
	}

	log.Warn("Encrypted files are not applied.")
	// Copy to temp folder quickly to fake secrets.
	tmpDir, err := os.MkdirTemp("", "chezmoi-setup-*")
	if err != nil {
		return errors.AddContext(err, "could not create temporary directory")
	}
	defer func() { _ = os.RemoveAll(tmpDir) }()

	err = exec.NewCommandCtx("").Check(gexec.ExtCmdCp, "-r", args.dest+"/.", tmpDir)
	if err != nil {
		return errors.AddContext(err, "could not copy '%s' to '%s'", args.dest, tmpDir)
	}

	err = fakeSecrets(tmpDir)
	if err != nil {
		return err
	}

	log.Info("Apply chezmoi config files.")
	err = exec.NewCommandCtx(filepath.Join(tmpDir, "components", "config")).
		Check(gexec.ExtCmdChezmoi,
			"-S", ".",
			"--force",
			"--no-tty",
			"--no-pager",
			"--refresh-externals=never",
			"apply", "--exclude", "encrypted")
	if err != nil {
		return errors.AddContext(err, "chezmoi apply failed")
	}

	log.Info("Chezmoi apply successful.")

	return nil
}

func initRepo(args *configSetupArgs) error {
	if !fs.Exists(args.dest) {
		log.Info("Init chezmoi.", "workspace", args.workspace)
		clean(args.dest)

		log.Info("Create temporary Git repo.")
		err := os.MkdirAll(args.dest, 0o755) //nolint:mnd // Directory permissions.
		if err != nil {
			return errors.AddContext(err, "could not create '%s'", args.dest)
		}

		gitx := newGitCtx(args.dest)
		err = gitx.Chain().
			Check("init").
			Check("remote", "add", "origin", args.url).
			Check("checkout", "-b", "feat/first-init-to-reset-to-main").
			Error()
		if err != nil {
			return err
		}

		log.Info("Copy store content.", "store", args.store, "dest", args.dest)
		err = exec.NewCommandCtx("").Check(gexec.ExtCmdCp,
			"-r", "--no-dereference", "--preserve=links",
			args.store+"/.", args.dest+"/")
		if err != nil {
			return errors.AddContext(err, "could not copy '%s' to '%s'", args.store, args.dest)
		}

		err = makeWritable(args.dest)
		if err != nil {
			return err
		}

		err = gitx.Chain().
			Check("add", ".").
			Check("commit", "-a", "-m", "feat: init temporary").
			Error()
		if err != nil {
			return err
		}

		// Make the init pass with the prompt in `.chezmoi.yaml.tmpl`.
		log.Info("Init chezmoi ...")
		err = exec.NewCommandCtx(args.dest).
			Check(gexec.ExtCmdChezmoi, "init", "--promptChoice", "Workspace?="+args.workspace)
		if err != nil {
			return errors.AddContext(err, "chezmoi init failed")
		}
	} else {
		log.Infof("Chezmoi already setup. To forcefully rerun use:\n"+
			"gabyx nixos config-setup --force "+
			"--url '%s' --ref '%s' --workspace '%s' --store '%s' --dest '%s'",
			args.url, args.ref, args.workspace, args.store, args.dest)
	}

	_, err := newGitCtx(args.dest).Get("rev-parse", "HEAD")
	if err != nil {
		return errors.AddContext(err, "dir '%s' does not seem to be a Git repo", args.dest)
	}

	return nil
}

// newGitCtx returns a Git command context in `dir` with a fixed user and default branch.
func newGitCtx(dir string) *exec.CmdContext {
	return exec.NewCmdCtxBuilder().
		Cwd(dir).
		BaseCmd(gexec.ExtCmdGit).
		BaseArgs(
			"-c", "user.name=nixos",
			"-c", "init.defaultBranch=main",
			"-c", "user.email=nixos@noreply.com").
		Build()
}

// clean removes `dest` and the chezmoi config directory. Errors are ignored.
func clean(dest string) {
	_ = os.RemoveAll(dest)

	home, err := os.UserHomeDir()
	if err == nil {
		_ = os.RemoveAll(filepath.Join(home, ".config/chezmoi"))
	}
}

// fakeSecrets writes a dummy file to the target of each `*.age` symlink in
// `<root>/components/config` to make `chezmoi apply ...` work if the
// `secrets` submodule is not checked out.
func fakeSecrets(root string) error {
	log.Info("Fake all secrets.", "dir", root)

	configDir := filepath.Join(root, "components", "config")

	links, _, err := fs.FindFiles(
		configDir,
		fs.WithPathFilter(func(p string, d os.DirEntry) bool {
			return d.Type()&os.ModeSymlink != 0 && strings.HasSuffix(p, ".age")
		}, true))
	if err != nil {
		return errors.AddContext(err, "could not find secret symlinks in '%s'", configDir)
	}

	for _, link := range links {
		target, e := os.Readlink(link)
		if e != nil {
			return errors.AddContext(e, "could not read symlink '%s'", link)
		}

		if !filepath.IsAbs(target) {
			target = filepath.Join(filepath.Dir(link), target)
		}

		e = os.MkdirAll(filepath.Dir(target), 0o755) //nolint:mnd // Directory permissions.
		if e != nil {
			return errors.AddContext(e, "could not create directory for '%s'", target)
		}

		e = os.WriteFile(
			target,
			[]byte("dummy-file\n"),
			0o644,
		) //nolint:mnd,gosec // File permissions.
		if e != nil {
			return errors.AddContext(e, "could not write dummy secret '%s'", target)
		}
	}

	return nil
}

// makeWritable adds write permission for the owner to all files and
// directories below `root` (like `chmod -R u+w`). Symlinks are not followed.
func makeWritable(root string) error {
	return filepath.WalkDir(root, func(p string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if d.Type()&os.ModeSymlink != 0 {
			return nil
		}

		info, err := d.Info()
		if err != nil {
			return err
		}

		return os.Chmod(p, info.Mode().Perm()|0o200) //nolint:mnd // Owner write bit.
	})
}
