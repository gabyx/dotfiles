{
  symlinkJoin,
  gcalcli,
  makeWrapper,
}:
symlinkJoin {
  name = "gcalcli";
  paths = [ gcalcli ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/gcalcli" --add-flags '--config-folder "$HOME/.config/gcalcli"'
  '';
}
