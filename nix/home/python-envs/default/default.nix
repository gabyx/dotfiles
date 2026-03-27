{ pkgs, ... }:
pkgs.python313.withPackages (ps: [
  ps.matplotlib
  ps.numpy

  ps.mypy
  ps.black
])
