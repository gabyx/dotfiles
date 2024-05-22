{lib, ...}:
with lib.hm.gvariant; {
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
      use-default-reminder = true;
      use-markdown-editor = true;
      week-start-day-name = "monday";
      work-day-friday = true;
      work-day-monday = true;
      work-day-saturday = false;
      work-day-sunday = false;
      work-day-thursday = true;
      work-day-tuesday = true;
      work-day-wednesday = true;
    };

    "org/gnome/evolution/mail" = {
      browser-close-on-reply-policy = "ask";
      composer-mode = "markdown-html";
      composer-show-from-override = false;
      composer-signature-in-new-only = true;
      composer-visually-wrap-long-lines = false;
      forward-style-name = "attached";
      image-loading-policy = "never";
      junk-check-custom-header = true;
      junk-empty-on-exit-days = 0;
      junk-lookup-addressbook = false;
      message-list-sort-on-header-click = "always";
      prompt-check-if-default-mailer = false;
      prompt-on-composer-mode-switch = false;
      prompt-on-unwanted-html = false;
      reply-style-name = "quoted";
      show-to-do-bar = false;
      trash-empty-on-exit-days = 0;
    };

    "org/gnome/evolution/plugin/mail-notification" = {
      notify-sound-beep = false;
    };
  };
}
