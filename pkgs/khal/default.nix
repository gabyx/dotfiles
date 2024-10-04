{
  lib,
  stdenv,
  fetchFromGitHub,
  glibcLocales,
  installShellFiles,
  python3,
}:
# We need latest calendar CLI on `main` with `--json` support.
python3.pkgs.buildPythonApplication rec {
  pname = "khal";
  version = "0.12.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gabyx";
    repo = "khal";
    rev = "fc8fef57e9382a2f1754205b82e6353b1db2b848";
    hash = "sha256-azkyxuJ/OgxARYgQqP7728InfkIHlP8pL4Bwv8/+5sQ=";
  };

  nativeBuildInputs =
    [
      glibcLocales
      installShellFiles
    ]
    ++ (with python3.pkgs; [
      setuptools-scm
      sphinx
      sphinxcontrib-newsfeed
    ]);

  propagatedBuildInputs = with python3.pkgs; [
    atomicwrites
    click
    click-log
    configobj
    freezegun
    icalendar
    lxml
    pkginfo
    vdirsyncer
    python-dateutil
    pytz
    pyxdg
    requests-toolbelt
    tzlocal
    urwid
  ];

  nativeCheckInputs = with python3.pkgs; [
    freezegun
    hypothesis
    packaging
    pytestCheckHook
    vdirsyncer
  ];

  postInstall = ''
    # shell completions
    installShellCompletion --cmd khal \
      --bash <(_KHAL_COMPLETE=bash_source $out/bin/khal) \
      --zsh <(_KHAL_COMPLETE=zsh_source $out/bin/khal) \
      --fish <(_KHAL_COMPLETE=fish_source $out/bin/khal)

    # man page
    PATH="${
      python3.withPackages (
        ps: with ps; [
          sphinx
          sphinxcontrib-newsfeed
        ]
      )
    }/bin:$PATH" \
    make -C doc man
    installManPage doc/build/man/khal.1

    # .desktop file
    install -Dm755 misc/khal.desktop -t $out/share/applications
  '';

  doCheck = !stdenv.isAarch64;

  LC_ALL = "en_US.UTF-8";

  disabledTests = [
    # timing based
    "test_etag"
    "test_bogota"
    "test_event_no_dst"
  ];

  meta = with lib; {
    description = "CLI calendar application";
    homepage = "http://lostpackets.de/khal/";
    changelog = "https://github.com/pimutils/khal/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ gebner ];
  };
}
