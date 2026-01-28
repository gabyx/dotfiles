# Ref: https://raw.githubusercontent.com/EmergentMind/nix-config/refs/heads/dev/modules/hosts/common/yubikey.nix
# Video: https://www.youtube.com/watch?v=3CeXbONjIgE

# This module supports multiple YubiKey 4 and/or 5 devices as well as a single Yubico Security Key device.
# The limitation to a single Security Key is because they do not have serial numbers and therefore the
# scripts in this module cannot uniquely identify them. See options.yubikey.identifies.description below
# for information on how to add a 'mock' serial number for a single Security key. Additional context is
# available in Issue 14 https://github.com/EmergentMind/nix-config/issues/14
{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:
let
  homeDir = "${config.settings.user.home}";
  userName = "${config.settings.user.name}";

  windowMgr = config.settings.windowing.manager;

in
{
  options = {
    yubikey = {
      enable = lib.mkEnableOption "Enable Yubikey support.";
      identifiers = lib.mkOption {
        default = { };
        type = lib.types.attrsOf (lib.types.either lib.types.int lib.types.str);
        description = ''
          Attrset of key file name (`.ssh/<keyfile>.pub`) to Yubikey serial numbers.
                  NOTE: Yubico's 'Security Key' products do not use unique serial number therefore, the scripts in this module
                  are unable to distinguish between multiple 'Security Key' devices and instead will detect a
                  Security Key serial number as the string \"[FIDO]\".
                  This means you can only use a single Security Key but can still mix it with YubiKey 4 and 5 devices.'';
        example = lib.literalExample ''
          {
            foo = 12345678;
            bar = 87654321;
            baz = "[FIDO]";
          }
        '';
      };
      autoScreenUnlock = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "Unlock screen on yubikey insert";
      };
      autoScreenLock = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "Lock screen on yubikey removal";
      };

      autoScreenLockCmd = lib.mkOption {
        default =
          if windowMgr == "sway" then
            "${lib.getExe pkgs.swaylock-effects} --grace 0 -f"
          else
            "${lib.getExe pkgs.hyperlock}";
        type = lib.types.str;
        description = "Lock command to lock the screen.";
      };
    };
  };
  config =
    let
      yubikey-up =
        let
          yubikeyIds = lib.concatStringsSep " " (
            lib.mapAttrsToList (name: id: "[${name}]=\"${toString id}\"") config.yubikey.identifiers
          );
        in
        pkgs.writeShellApplication {
          name = "yubikey-up";
          runtimeInputs = lib.attrValues { inherit (pkgs) gawk yubikey-manager; };
          text =
            # bash
            ''
              #!/usr/bin/env bash
              set -euo pipefail

              serial=$(ykman list | awk '{print $NF}')
              # If it got unplugged before we ran, just don't bother
              if [ -z "$serial" ]; then
                # FIXME(yubikey): Warn probably
                exit 0
              fi

              declare -A serials=(${yubikeyIds})

              key_name=""
              for key in "''${!serials[@]}"; do
                if [[ $serial == "''${serials[$key]}" ]]; then
                  key_name="$key"
                fi
              done

              if [ -z "$key_name" ]; then
                echo WARNING: Unidentified yubikey with serial "$serial" . Won\'t link an SSH key.
                exit 0
              fi

              echo "Creating links to '${homeDir}/$key_name'."
              ln -sf "${homeDir}/.ssh/$key_name" "${homeDir}/.ssh/id_yubikey"
              ln -sf "${homeDir}/.ssh/$key_name.pub" "${homeDir}/.ssh/id_yubikey.pub"

              echo "Changing permissions."
              chown -h "${userName}:users" "${homeDir}/.ssh/id_yubikey" "${homeDir}/.ssh/id_yubikey.pub"
            '';
        };

      yubikey-down = pkgs.writeShellApplication {
        name = "yubikey-down";
        text =
          # bash
          ''
            #!/usr/bin/env bash
            set -euo pipefail

            rm "${homeDir}/.ssh/id_yubikey"
            rm "${homeDir}/.ssh/id_yubikey.pub"
          '';
      };
    in
    lib.mkIf config.yubikey.enable {

      environment.systemPackages = [
        pkgsUnstable.gnupg
        pkgsUnstable.yubikey-manager # cli-based authenticator tool. accessed via `ykman`
        pkgs.pam_u2f # for yubikey with sudo
        pkgsUnstable.yubioath-flutter # gui-based authenticator tool. yubioath-desktop on older nixpkg channels

        yubikey-up
        yubikey-down
      ];

      # Yubikey required services and config.
      services = {
        #yubikey-agent.enable = true;

        udev.extraRules =
          lib.optionalString pkgs.stdenv.isLinux ''
            # Link/unlink ssh key on yubikey add/remove
            SUBSYSTEM=="usb", ACTION=="add", ATTR{idVendor}=="1050", RUN+="${lib.getBin yubikey-up}/bin/yubikey-up"

            # NOTE: Yubikey 4 has a ID_VENDOR_ID on remove, but not Yubikey 5 BIO, whereas both have a HID_NAME.
            # Yubikey 5 HID_NAME uses "YubiKey" whereas Yubikey 4 uses "Yubikey", so matching on "Yubi" works for both

            SUBSYSTEM=="hid", ACTION=="remove", ENV{HID_NAME}=="Yubico Yubi*", RUN+="${lib.getBin yubikey-down}/bin/yubikey-down"
          ''
          + lib.optionalString config.yubikey.autoScreenLock ''
            # Lock the device if you remove the yubikey (use udevadm monitor -p to debug)
            SUBSYSTEM=="hid", ACTION=="remove", ENV{HID_NAME}=="Yubico Yubi*", RUN+="${config.yubikey.autoScreenLockCmd}"
          ''
          + lib.optionalString config.yubikey.autoScreenUnlock ''
            SUBSYSTEM=="hid",\
             ACTION=="add",\
             ENV{HID_NAME}=="Yubico Yubi*",\
             RUN+="${pkgs.systemd}/bin/loginctl activate 1"
          '';

        udev.packages = [ pkgs.yubikey-personalization ];
        pcscd.enable = true; # smartcard service
      };

      programs.yubikey-touch-detector.enable = true;

      # Yubikey login / sudo.
      security.pam = {
        u2f = {
          enable = true;
          settings = {
            cue = true; # Tells user they need to press the button
            authFile = "${homeDir}/.config/yubikey/u2f_keys";
          };
        };
        services = {
          login.u2fAuth = true;
          sudo.u2fAuth = true;
        };
      };
    };
}
