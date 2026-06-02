{
  lib,
  pkgsUnstable,
  ...
}:
let
  explorer = [ "thunar.desktop" ];
  browser = [ "zen.desktop" ];
  calendar = [ "org.gnome.Evolution.desktop" ];
  signal = [ "signal-desktop.desktop" ];
  archiver = [ "org.gnome.FileRoller.desktop" ];
  pdf = [ "org.pwmt.zathura.desktop" ];
  images = [
    "swappy.desktop"
    "sxiv.desktop"
    "org.nomacs.ImageLounge.desktop"
    "org.kde.krita.desktop"
  ]
  ++ pdf
  ++ browser;
  audio = [ "vlc.desktop" ];
  video = [ "vlc.desktop" ];

  mimeGroups = {
    files = [
      "inode/directory"
    ];

    browser = [
      "text/html"
      "application/xhtml+xml"
      "application/json"
      "application/x-extension-htm"
      "application/x-extension-html"
      "application/x-extension-shtml"
      "application/x-extension-xhtml"
      "application/x-extension-xht"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/ftp"
      "x-scheme-handler/chrome"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ];

    archiver = [
      "application/zip"
      "application/x-tar"
      "application/gzip"
      "application/x-bzip2"
      "application/x-7z-compressed"
      "application/vnd.rar"
      "application/x-iso9660-image"
      "application/x-lzh-compressed"
      "application/x-xz"
      "application/vnd.ms-cab-compressed"
      "application/x-arj"
      "application/x-lzip"
      "application/x-compress"
      "application/x-cpio"
      "application/x-ace-compressed"
      "application/x-lzma"
    ];

    images = [
      "image/png"
      "image/jpeg"
      "image/tiff"
      "image/gif"
      "image/webp"
      "image/svg+xml"
      "image/bmp"
    ];

    audio = [
      "audio/mpeg"
      "audio/ogg"
      "audio/flac"
      "audio/wav"
      "audio/aac"
      "audio/x-m4a"
    ];

    video = [
      "video/mp4"
      "video/x-matroska"
      "video/webm"
      "video/x-msvideo"
      "video/quicktime"
    ];

    pdf = [
      "application/pdf"
    ];

    calendar = [
      "text/calendar"
    ];

    signal = [
      "x-scheme-handler/file"
      "x-scheme-handler/sgnl"
      "x-scheme-handler/signalcaptcha"
    ];
  };

  mkAssoc = appList: mimes: lib.genAttrs mimes (_: appList);

  associations =
    mkAssoc browser mimeGroups.browser
    // mkAssoc explorer mimeGroups.files
    // mkAssoc archiver mimeGroups.archiver
    // mkAssoc images mimeGroups.images
    // mkAssoc audio mimeGroups.audio
    // mkAssoc video mimeGroups.video
    // mkAssoc signal mimeGroups.signal
    // mkAssoc pdf mimeGroups.pdf
    // mkAssoc calendar mimeGroups.calendar;

  checkMimeApps = pkgsUnstable.writeTextFile {
    name = "check-mime-apps";
    destination = "/bin/check-mime-apps";
    executable = true;
    text =
      # Nu
      ''
        #!${pkgsUnstable.nushell}/bin/nu

        let mimeapps = ($env.HOME + "/.config/mimeapps.list")
        let search_paths = [
          "/run/current-system/sw/share/applications"
          ($env.HOME + "/.local/share/applications")
          "/nix/store"
        ]

        let parsed = (open $mimeapps | from ini)
        let sections = ["Default Applications" "Added Associations"]

        $sections
        | where { |s| $parsed | columns | any { |c| $c == $s } }
        | each { |section|
            $parsed
            | get $section
            | transpose mime apps
            | each { |row|
                let apps = ($row.apps | split row ";" | where { |a| $a != "" })
                $apps | each { |app|
                  print $"Checking apps '($apps)'"
                  let found = ($search_paths | any { |p|
                    ([$p $app] | path join | path exists)
                  })
                  if not $found {
                    print $"WARNING: ($section) — ($row.mime) references missing desktop file: ($app)"
                  }
                }
              }
          }
      '';
  };
in
{
  home.packages = [ checkMimeApps ];
  home.activation.checkMimeApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${checkMimeApps}/bin/check-mime-apps
  '';

  # Enable all XDG directories.
  xdg.enable = true;

  # Set some file associations.
  xdg.mimeApps.enable = true;
  xdg.mimeApps.associations.added = associations;
  xdg.mimeApps.defaultApplications = associations;
}
