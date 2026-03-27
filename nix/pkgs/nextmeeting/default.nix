{
  lib,
  fetchFromGitHub,
  python3,
  gcalcli,
  libnotify,
}:
# TODO: That should become our nextmeeting script.
#       This is not used.
with python3.pkgs;
buildPythonApplication rec {
  pname = "nextmeeting";
  version = "1.5.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chmouel";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-Vaq3wht93OlodpBCDDM8NBlJmPSIObU8iryU7tSfh/c=";
  };

  propagatedBuildInputs = [
    python-dateutil
    poetry-core
    gcalcli
    libnotify
  ];

  doCheck = true;

  meta = with lib; {
    description = "Show your google calendar next meeting in your waybar or polybar.";
    mainProgram = pname;
    homepage = "https://github.com/chmouel/nextmeeting";
    license = licenses.mit;
    maintainers = with maintainers; [ gabyx ];
  };
}
