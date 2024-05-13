{config, ...}: let
  realName = "Gabriel Nützi";
  at = "@";
  defaultAddress = "gnuetzi" + at + "gmail.com";
  workAddress = "nuetzig" + at + "ethz.ch";
in {
  programs.thunderbird = {
    enable = true;
    profiles."nixos" = {
      isDefault = true;
    };
  };

  accounts.email.accounts =
    {
      "${defaultAddress}" = {
        realName = realName;
        address = defaultAddress;

        userName = defaultAddress;
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
      if config.settings.setupWorkEmail
      then {
        "${workAddress}" = {
          realName = realName;
          address = workAddress;

          userName = workAddress;
          primary = false;

          thunderbird = {
            enable = true;
            profiles = ["nixos"];

            perIdentitySettings = id: {
              "mail.server.smtp_${id}.authMethod" = 3; # Normal password.
              "mail.smtpserver.smtp_${id}.authMethod" = 3; # Normal password.
            };
          };

          imap.host = "mail.ethz.ch";
          imap.port = 993;
          imap.tls.enable = true;

          smtp.host = "mail.ethz.ch";
          smtp.port = 587;
          smtp.tls.enable = true;
        };
      }
      else {}
    );
}
