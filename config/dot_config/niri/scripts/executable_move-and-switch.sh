#!/usr/bin/env bash
niri msg action move-window-to-workspace "$1"
niri msg action focus-workspace "$1"
