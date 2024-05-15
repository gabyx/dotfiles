{
  lib,
  config,
  ...
}: let
  imapFolder = email: imapHost: path: "imap://${lib.replaceStrings ["@"] ["%40"] email}@${imapHost}/${path}";

  # Place all sent/drafts/archive/templates inside the respective folder on
  # the imap storage.
  # Thunderbird otherwise puts them into a local folder.
  identitySettingsFolders = id: email: imapHost: {
    # "mail.identity.id_${id}.fcc_folder_picker_mode" = 0;
    "mail.identity.id_${id}.fcc_folder" = imapFolder email imapHost "Sent";
    # "mail.identity.id_${id}.draft_folder_picker_mode" = 0;
    "mail.identity.id_${id}.draft_folder" = imapFolder email imapHost "Drafts";
    # "mail.identity.id_${id}.archive_folder_picker_mode" = 0;
    "mail.identity.id_${id}.archive_folder" = imapFolder email imapHost "Archive";
    # "mail.identity.id_${id}.stationary_folder_picker_mode" = 0;
    "mail.identity.id_${id}.stationary_folder" = imapFolder email imapHost "Templates";
  };
in {
  programs.thunderbird = {
    enable = true;
    profiles."nixos" = {
      isDefault = true;
    };
  };

  accounts.email.accounts =
    {
      "${config.settings.user.email}" = rec {
        realName = config.settings.user.name;
        address = config.settings.user.email;

        userName = address;
        primary = true;

        thunderbird = {
          enable = true;
          profiles = ["nixos"];

          perIdentitySettings = id: {
            "mail.server.server_${id}.authMethod" = 10; # OAuth2
            "mail.smtpserver.smtp_${id}.authMethod" = 10; # OAuth2
          };
        };

        imap.host = "imap.gmail.com";
        imap.port = 993;
        imap.tls.enable = true;

        smtp.host = "smtp.gmail.com";
        smtp.port = 465;
        smtp.tls.enable = true;
      };
    }
    // (
      if config.settings.user.emailWorkEnable
      then {
        "${config.settings.user.emailWork}" = rec {
          realName = config.settings.user.name;
          address = config.settings.user.emailWork;

          userName = address;
          primary = false;

          thunderbird = {
            enable = true;
            profiles = ["nixos"];

            perIdentitySettings = id:
              {
                "mail.server.smtp_${id}.authMethod" = 3; # Normal password.
                "mail.smtpserver.smtp_${id}.authMethod" = 3; # Normal password.
              }
              // identitySettingsFolders id address imap.host;
          };

          imap.host = "mail.ethz.ch";
          imap.port = 993;
          imap.tls.enable = true;

          smtp.host = "mail.ethz.ch";
          smtp.port = 587;
          smtp.tls.enable = true;
          smtp.tls.useStartTls = true;
        };
      }
      else {}
    );
}
