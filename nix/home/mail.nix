{ lib, ... }:
with lib.hm.gvariant;
{
  dconf.settings = {
    "org/gnome/calendar" = {
      active-view = "week";
    };

    "org/gnome/evolution" = {
      default-mail-account = "0f9b0823dc42b16d3a5d6f97902882e2c7e0b50f";
      default-mail-identity = "f22fd06697ff4c9554aaba7d95d963b3d3aee73e";
    };

    "org/gnome/evolution/calendar" = {
      allow-direct-summary-edit = true;
      confirm-purge = true;
      editor-show-timezone = true;
      prefer-new-item = "event-new";
      time-divisions = 10;
      time-zone = "Europe/Zurich";
      use-default-reminder = true;
      use-markdown-editor = true;
      week-start-day-name = "monday";
      work-day-monday = true;
      work-day-tuesday = true;
      work-day-wednesday = true;
      work-day-thursday = true;
      work-day-friday = true;
      work-day-saturday = false;
      work-day-sunday = false;
    };

    "org/gnome/evolution/mail" = {
      browser-close-on-reply-policy = "ask";
      composer-mode = "markdown-html";
      composer-request-dsn = true;
      composer-request-receipt = true;
      composer-show-from-override = false;
      composer-sign-reply-if-signed = false;
      composer-signature-in-new-only = true;
      composer-spell-languages = [ "en_US" ];
      composer-visually-wrap-long-lines = false;
      forward-style = 1;
      forward-style-name = "inline";
      image-loading-policy = "never";
      junk-check-custom-header = true;
      junk-empty-on-exit-days = 0;
      junk-lookup-addressbook = false;
      mark-seen-timeout = 0;
      message-list-sort-on-header-click = "always";
      prompt-check-if-default-mailer = false;
      prompt-on-accel-send = false;
      prompt-on-composer-mode-switch = false;
      prompt-on-empty-subject = false;
      prompt-on-mark-all-read = false;
      prompt-on-unwanted-html = false;
      reply-style = 3;
      reply-style-name = "outlook";
      show-to-do-bar = false;
      trash-empty-on-exit = true;
      trash-empty-on-exit-days = 30;
    };

    "org/gnome/evolution/plugin/mail-notification" = {
      notify-sound-beep = true;
    };
  };
}
