{ pkgs, ... }:
pkgs.python311.withPackages (ps: [
  ps.matplotlib
  ps.numpy

  ps.mypy
  ps.black
])
