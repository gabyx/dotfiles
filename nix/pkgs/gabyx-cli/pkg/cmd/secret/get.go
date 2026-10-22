package secretcmd

import (
	"encoding/json"
	"fmt"
	"os"
	"path"
	"path/filepath"
	"strings"

	"gabyx-cli/pkg/prompt"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	fs "github.com/gabyx/quitsh/pkg/filesystem"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

const longDescGet = `
    Retrieves a secret from Bitwarden or a prompt.
    If 'BW_SESSION' is not set, Bitwarden is unlocked (or logged into) first.
    If a Yubikey is present, the secret is encrypted with the Yubikey-backed
    age identity to '<file>.<yubikey>.age-fido' and decrypted from that file
    on further invocations.
    The secret is written to stdout.
`

// Bitwarden item IDs of the FIDO2 age identities per Yubikey.
//
//nolint:gochecknoglobals // Allowed for constant definitions.
var bwFidoAgeIDs = map[string]string{
	"normal": "cc76135e-8375-490f-b884-b41a013aa9c5",
	"s1":     "14c8d52d-0f1f-4584-b1b4-b41a013ce86a",
	"s2":     "4d5af98d-1792-47f6-b4c7-b41a013d00b3",
}

type getArgs struct {
	bwID       string
	bwField    string
	yubikey    string
	prompt     string
	filePrefix string
}

func addGetCmd(parent *cobra.Command) {
	var args getArgs

	cmd := &cobra.Command{
		Use:   "get",
		Short: "Get a secret from Bitwarden or a prompt, cached with a Yubikey.",
		Long:  longDescGet,
		Example: "  gabyx secret get -b my-secret-id -y normal -f /tmp/secret\n" +
			"  gabyx secret get --bw-id id --yubikey s1 --prompt 'Enter secret: ' --file /tmp/secret",
		Args: cobra.NoArgs,
		PreRunE: func(_cmd *cobra.Command, _args []string) error {
			if args.bwID == "" && args.prompt == "" {
				return errors.New("either '--bw-id' or '--prompt' must be provided")
			}

			if args.yubikey == "" {
				return errors.New("no '--yubikey' given")
			}

			return nil
		},
		RunE: func(_cmd *cobra.Command, _args []string) error {
			return getSecret(&args)
		},
	}

	cmd.Flags().
		StringVarP(&args.bwID, "bw-id", "b", "", "Bitwarden item ID.")
	cmd.Flags().
		StringVarP(&args.bwField, "bw-field", "B", "password",
			"Bitwarden item field to extract (nested fields with '.', e.g. 'login.password').")
	cmd.Flags().
		StringVarP(&args.yubikey, "yubikey", "y", os.Getenv("YUBIKEY_NAME"),
			"Yubikey name (default from env. 'YUBIKEY_NAME').")
	cmd.Flags().
		StringVarP(&args.prompt, "prompt", "p", "", "Prompt text for the fallback prompt.")
	cmd.Flags().
		StringVarP(&args.filePrefix, "file", "f", "", "File prefix path for the encrypted file.")
	_ = cmd.MarkFlagRequired("file")

	parent.AddCommand(cmd)
}

func getSecret(args *getArgs) error {
	if !isYubikeyPresent() {
		log.Info("No Yubikey present.")

		secret, err := getBitwardenOrPrompt(args.bwID, args.bwField, args.prompt)
		if err != nil {
			return err
		}

		_, _ = fmt.Fprintln(os.Stdout, secret)
		log.Info("Secret retrieved.")

		return nil
	}

	log.Info("Yubikey seems present.")

	identity, err := getFidoIdentity(args.yubikey, args.bwField)
	if err != nil {
		return err
	}

	identityFile, err := writeTempFile(identity)
	if err != nil {
		return err
	}
	defer func() { _ = os.Remove(identityFile) }()

	encFile := fmt.Sprintf("%s.%s.age-fido", args.filePrefix, args.yubikey)
	if !fs.Exists(encFile) {
		log.Info(
			"Encryption file does not exist, writing it for further invocations.",
			"path", encFile, "yubikey", args.yubikey)

		err = writeEncryptedFile(args, identityFile, encFile)
		if err != nil {
			return err
		}
	}

	err = exec.NewCmdCtxBuilder().
		Build().
		Check("age", "-d", "-i", identityFile, encFile)
	if err != nil {
		return errors.AddContext(err, "decrypting '%s' failed", encFile)
	}

	log.Info("Secret retrieved.")

	return nil
}

func isYubikeyPresent() bool {
	out, err := exec.NewCmdCtxBuilder().Quiet().Build().Get("ykman", "list")
	if err != nil {
		log.Debug("Could not list Yubikeys.", "error", err)

		return false
	}

	return out != ""
}

func getFidoIdentity(yubikey string, bwField string) (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}

	file := path.Join(home, ".config", "age", fmt.Sprintf("gabyx-%s-fido2-hmac.identity", yubikey))
	if fs.Exists(file) {
		content, e := os.ReadFile(file)
		if e != nil {
			return "", e
		}

		return string(content), nil
	}

	log.Info("FIDO2 age identity does not exist.", "path", file)

	return getBitwardenOrPrompt(
		bwFidoAgeIDs[yubikey],
		bwField,
		fmt.Sprintf("Enter FIDO2 age identity created with Yubikey '%s': ", yubikey))
}

func writeEncryptedFile(args *getArgs, identityFile string, encFile string) error {
	err := os.MkdirAll(filepath.Dir(encFile), fs.DefaultPermissionsDir)
	if err != nil {
		return err
	}

	secret, err := getBitwardenOrPrompt(args.bwID, args.bwField, args.prompt)
	if err != nil {
		return err
	}

	tmp, err := os.CreateTemp(filepath.Dir(encFile), ".age-fido-*")
	if err != nil {
		return err
	}
	tmp.Close()
	defer func() { _ = os.Remove(tmp.Name()) }()

	log.Info("Writing encrypted file.", "path", encFile)
	err = exec.NewCmdCtxBuilder().
		Build().
		WithStdin(strings.NewReader(secret+"\n")).
		Check("age", "-e", "-i", identityFile, "-o", tmp.Name())
	if err != nil {
		return errors.AddContext(err, "could not encrypt to '%s'", encFile)
	}

	err = os.Rename(tmp.Name(), encFile)
	if err != nil {
		return err
	}

	return os.Chmod(encFile, 0o400)
}

func getBitwardenOrPrompt(bwID string, bwField string, promptTitle string) (string, error) {
	secret, err := getBitwarden(bwID, bwField)
	if err == nil {
		return secret, nil
	}
	log.Debug("Could not get secret from Bitwarden.", "error", err)

	if promptTitle == "" {
		return "", errors.New("could not get secret from Bitwarden and no prompt given")
	}

	secret, err = prompt.Get(promptTitle, true)
	if err != nil {
		return "", errors.AddContext(err, "could not get secret from Bitwarden or prompt")
	}

	return secret, nil
}

func getBitwarden(id string, field string) (string, error) {
	if id == "" {
		return "", errors.New("no Bitwarden ID given")
	}

	err := ensureBitwardenSession()
	if err != nil {
		return "", err
	}

	log.Info("Getting secret from Bitwarden.", "id", id, "field", field)
	out, err := exec.NewCmdCtxBuilder().Quiet().Build().Get("bw", "get", "item", id)
	if err != nil {
		return "", err
	}

	var item any
	err = json.Unmarshal([]byte(out), &item)
	if err != nil {
		return "", errors.AddContext(err, "could not parse Bitwarden item")
	}

	value, err := extractField(item, field)
	if err != nil {
		return "", err
	}

	return value, nil
}

// extractField returns the value at the `.`-separated `field` path in `item`.
func extractField(item any, field string) (string, error) {
	v := item
	for key := range strings.SplitSeq(field, ".") {
		m, ok := v.(map[string]any)
		if !ok {
			return "", errors.New("could not extract field '%s'", field)
		}

		v, ok = m[key]
		if !ok {
			return "", errors.New("could not extract field '%s'", field)
		}
	}

	var s string
	switch val := v.(type) {
	case string:
		s = val
	case nil:
		s = ""
	default:
		b, err := json.Marshal(val)
		if err != nil {
			return "", err
		}
		s = string(b)
	}

	if s == "" {
		return "", errors.New("field '%s' is empty", field)
	}

	return s, nil
}

func writeTempFile(content string) (string, error) {
	f, err := os.CreateTemp("", "gabyx-secret-*")
	if err != nil {
		return "", err
	}
	defer func() { _ = f.Close() }()

	_, err = f.WriteString(content)
	if err != nil {
		e := os.Remove(f.Name())

		return "", errors.Combine(err, e)
	}

	return f.Name(), nil
}
