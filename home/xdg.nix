{
  lib,
  pkgs,
  pkgsStab,
  inputs,
  ...
}:
let
  browser = [ "google-chrome.desktop" ];
  archiver = [ "file-roller.desktop" ];

  associations = {
    "text/html" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/ftp" = browser;

    "x-scheme-handler/chrome" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;

    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;

    "image/*" = "nomacs.desktop";
    "audio/*" = [ "vlc.desktop" ];
    "video/*" = [ "vlc.desktop" ];

    # Archives
    "application/zip" = archiver;
    "application/x-tar" = archiver;
    "application/gzip" = archiver;
    "application/x-bzip2" = archiver;
    "application/x-7z-compressed" = archiver;
    "application/vnd.rar" = archiver;
    "application/x-iso9660-image" = archiver;
    "application/x-lzh-compressed" = archiver;
    "application/x-xz" = archiver;
    "application/vnd.ms-cab-compressed" = archiver;
    "application/x-arj" = archiver;
    "application/x-lzip" = archiver;
    "application/x-compress" = archiver;
    "application/x-cpio" = archiver;
    "application/x-ace-compressed" = archiver;
    "application/x-lzma" = archiver;

    "text/calendar" = [ "thunderbird.desktop" ]; # ".ics"  iCalendar format

    "application/json" = browser; # ".json"  JSON format
    "application/pdf" = browser ++ [ "com.github.jeromerobert.pdfarranger.desktop" ];
  };
in
{
  # Enable all XDG directories.
  xdg.enable = true;

  # Set some file associations.
  xdg.mimeApps.enable = true;
  xdg.mimeApps.associations.added = associations;
  xdg.mimeApps.defaultApplications = associations;
}
