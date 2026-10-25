package containercmd

import (
	"regexp"
	"strings"

	gexec "gabyx-cli/pkg/exec"
	"gabyx-cli/pkg/sudo"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

func AddCmd(root *cobra.Command) {
	containerCmd := &cobra.Command{
		Use:   "container",
		Short: "Container (docker/podman) commands.",
	}

	var usePodman bool
	removeCmd := &cobra.Command{
		Use:   "remove-images <regex>",
		Short: "Remove images whose '<repository>:<tag>' fully matches 'regex'.",
		Args:  cobra.ExactArgs(1),
		RunE: func(_cmd *cobra.Command, args []string) error {
			return removeImages(args[0], usePodman)
		},
	}
	removeCmd.Flags().
		BoolVar(&usePodman, "use-podman", false, "Use 'podman' instead of 'docker'.")

	toPodmanCmd := &cobra.Command{
		Use:   "images-to-podman <regex>",
		Short: "Copy docker images whose '<repository>:<tag>' fully matches 'regex' to podman.",
		Args:  cobra.ExactArgs(1),
		RunE: func(_cmd *cobra.Command, args []string) error {
			return imagesToPodman(args[0])
		},
	}

	containerCmd.AddCommand(removeCmd, toPodmanCmd)
	root.AddCommand(containerCmd)
}

func removeImages(regex string, usePodman bool) error {
	if regex == "" {
		return errors.New("empty regex given")
	}

	reg, err := regexp.Compile(`^(\w+)\|` + regex + `$`)
	if err != nil {
		return errors.AddContext(err, "could not compile regex '%s'", regex)
	}

	tool := gexec.ExtCmdDocker
	cmdx := sudo.NewCmdCtxBuilder().Quiet().Build()
	if usePodman {
		tool = gexec.ExtCmdPodman
		cmdx = exec.NewCmdCtxBuilder().Quiet().Build()
	}

	lines, err := cmdx.GetSplit(tool, "images", "--format", "{{.ID}}|{{.Repository}}:{{.Tag}}")
	if err != nil {
		return err
	}

	var ids []string
	for _, l := range lines {
		if strings.Contains(l, "<none>") {
			continue
		}

		if m := reg.FindStringSubmatch(l); m != nil {
			ids = append(ids, m[1])
		}
	}

	if len(ids) == 0 {
		log.Warn("No images found.")

		return nil
	}

	log.Info("Deleting images.", "ids", ids)
	for _, id := range ids {
		err = cmdx.Check(tool, "rmi", "--force", id)
		if err != nil {
			return err
		}
	}

	return nil
}

func imagesToPodman(regex string) error {
	const transport = "docker-daemon"

	if regex == "" {
		return errors.New("empty regex given")
	}

	reg, err := regexp.Compile(`^` + transport + `:` + regex + `$`)
	if err != nil {
		return errors.AddContext(err, "could not compile regex '%s'", regex)
	}

	log.Info("Copying images from docker to podman.", "regex", regex)
	lines, err := exec.NewCmdCtxBuilder().
		Quiet().
		Build().
		GetSplit(gexec.ExtCmdDocker, "images", "--format", transport+":{{.Repository}}:{{.Tag}}")
	if err != nil {
		return err
	}

	var images []string
	for _, l := range lines {
		if !strings.Contains(l, "<none>") && reg.MatchString(l) {
			images = append(images, l)
		}
	}

	if len(images) == 0 {
		log.Warn("No images found.")

		return nil
	}

	log.Info("Pulling images.", "images", images)

	return exec.NewCommandCtx(".").Check(append([]string{gexec.ExtCmdPodman, "pull"}, images...)...)
}
