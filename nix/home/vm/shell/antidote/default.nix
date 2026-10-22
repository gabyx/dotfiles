# FIXME: Remove once updated in nixpkgs.
{
  antidote,
  fetchFromGitHub,
}:
antidote.overrideAttrs {
  version = "2.0.9";
  src = fetchFromGitHub {
    owner = "mattmc3";
    repo = "antidote";
    tag = "v2.0.9";
    hash = "sha256-rACIuEv4xvYbN5WTunSBJJ7kSHAeymqeYa6GimKvvR8=";
  };
}
