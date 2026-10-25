package secretcmd

import (
	"os"
	"path"
	"strings"

	gexec "gabyx-cli/pkg/exec"
	"gabyx-cli/pkg/prompt"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

func AddCmd(root *cobra.Command) {
	secretCmd := &cobra.Command{
		Use:   "secret",
		Short: "Secret commands.",
	}

	addGetCmd(secretCmd)

	root.AddCommand(secretCmd)
}

// ensureBitwardenSession sets 'BW_SESSION' in the process environment
// by unlocking (or logging into) Bitwarden if it is not already set.
// The master password is prompted on stderr and passed to `bw`
// with the env. variable 'PASSWORD'.
func ensureBitwardenSession() error {
	if os.Getenv("BW_SESSION") != "" {
		return nil
	}

	bw := exec.NewCmdCtxBuilder().BaseCmd(gexec.ExtCmdBw).Build()

	loggedIn := false
	err := bw.CheckWithEC(exec.ExitCode0And1SuccessVar(&loggedIn), "login", "--check")
	if err != nil {
		return errors.AddContext(err, "could not check Bitwarden login status")
	}

	password, err := prompt.Get("Enter Bitwarden master password: ", true)
	if err != nil {
		return errors.AddContext(err, "could not get Bitwarden master password")
	}

	bwPass := exec.NewCmdCtxBuilder().
		BaseCmd(gexec.ExtCmdBw).
		Env("PASSWORD=" + password).
		Build()

	var session string
	if loggedIn {
		log.Info("Unlocking Bitwarden.")
		session, err = bwPass.Get("unlock", "--passwordenv", "PASSWORD", "--raw")
	} else {
		email, e := getBitwardenEmail()
		if e != nil {
			return e
		}

		var code string
		code, err = prompt.Get("Enter Bitwarden TFA code: ", false)
		if err != nil {
			return errors.AddContext(err, "could not get Bitwarden TFA code")
		}

		log.Info("Logging into Bitwarden.", "email", email)
		session, err = bwPass.Get(
			"login", email,
			"--passwordenv", "PASSWORD",
			"--code", code,
		)
	}

	if err != nil {
		return errors.AddContext(err, "could not get Bitwarden session")
	}

	return os.Setenv("BW_SESSION", session)
}

// getBitwardenEmail reads the Bitwarden login email from
// '~/.config/bitwarden/login'.
func getBitwardenEmail() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}

	file := path.Join(home, ".config", "bitwarden", "login")
	content, err := os.ReadFile(file)
	if err != nil {
		return "", errors.AddContext(err, "could not read Bitwarden login email from '%s'", file)
	}

	email := strings.TrimSpace(string(content))
	if email == "" {
		return "", errors.New("Bitwarden login email in '%s' is empty", file)
	}

	return email, nil
}
