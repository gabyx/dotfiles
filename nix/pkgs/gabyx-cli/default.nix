{
  lib,
  buildGo126Module,
  installShellFiles,
  makeWrapper,
  testers,
  # Runtime deps.
  git,
  zfs,
  expect,
  util-linux,
}:
let
  # The version from the `.component.yaml`.
  version = builtins.head (
    builtins.match ".*\nversion: ([^\n]+)\n.*" (builtins.readFile ./.component.yaml)
  );

  # Runtime dependencies appended to `PATH`.
  runtimeInputs = [
    git
    zfs
    expect
    util-linux # `lsblk`.
  ];

  self = buildGo126Module {
    inherit version;
    pname = "gabyx";

    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./go.mod
        ./go.sum
        ./cmd
        ./pkg
      ];
    };

    # This hash defines the fixed-output derivation of the dependencies (FOD).
    # Set it to `""` and run `just gabyx-cli::package-nix` to get the new hash.
    vendorHash = "sha256-FufTWAICMatjhSQyDx+FJ/y5yAGFUIE5vdsWscn83Ts=";

    nativeBuildInputs = [
      installShellFiles
      makeWrapper
    ];

    nativeCheckInputs = [ git ];

    ldflags = [
      "-s"
      "-w"
      "-X gabyx-cli/pkg/build.buildVersion=${version}"
    ];

    postInstall = ''
      installShellCompletion --cmd gabyx \
        --bash <($out/bin/gabyx completion bash) \
        --fish <($out/bin/gabyx completion fish) \
        --zsh <($out/bin/gabyx completion zsh)

      # `/run/wrappers/bin` contains the setuid `sudo` on NixOS.
      wrapProgram $out/bin/gabyx \
        --suffix PATH : "${lib.makeBinPath runtimeInputs}:/run/wrappers/bin"
    '';

    passthru = {
      inherit runtimeInputs;

      tests.version = testers.testVersion {
        package = self;
        command = "gabyx --version";
        inherit version;
      };
    };

    meta = {
      description = "Personal tooling CLI of gabyx built with quitsh.";
      homepage = "https://github.com/gabyx/dotfiles";
      license = lib.licenses.asl20;
      maintainers = [ "gabyx" ];
      mainProgram = "gabyx";
    };
  };
in
self
