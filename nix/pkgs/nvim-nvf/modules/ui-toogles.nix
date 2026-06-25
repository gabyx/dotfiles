{ ... }:
{
  vim.keymaps = [
    {
      mode = "n";
      key = "<Leader>ua";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.autopairs() end
      '';
      desc = "Toggle autopairs.";
    }
    {
      mode = "n";
      key = "<Leader>ub";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.background() end
      '';
      desc = "Toggle background.";
    }
    {
      mode = "n";
      key = "<Leader>ud";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.diagnostics() end
      '';
      desc = "Toggle diagnostics.";
    }
    {
      mode = "n";
      key = "<Leader>ug";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.signcolumn() end
      '';
      desc = "Toggle signcolumn.";
    }
    {
      mode = "n";
      key = "<Leader>u>";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.foldcolumn() end
      '';
      desc = "Toggle foldcolumn.";
    }
    {
      mode = "n";
      key = "<Leader>ui";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.indent() end
      '';
      desc = "Change indent setting.";
    }
    {
      mode = "n";
      key = "<Leader>uF";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.format_on_save() end
      '';
      desc = "Toggle format on save.";
    }
    {
      mode = "n";
      key = "<Leader>uf";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.format_on_save_buffer() end
      '';
      desc = "Toggle format on save (buffer).";
    }
    {
      mode = "n";
      key = "<Leader>ul";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.statusline() end
      '';
      desc = "Toggle statusline.";
    }
    {
      mode = "n";
      key = "<Leader>un";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.number() end
      '';
      desc = "Change line numbering.";
    }
    {
      mode = "n";
      key = "<Leader>up";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.paste() end
      '';
      desc = "Toggle paste mode.";
    }
    {
      mode = "n";
      key = "<Leader>us";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.spell() end
      '';
      desc = "Toggle spellcheck.";
    }
    {
      mode = "n";
      key = "<Leader>uS";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.conceal() end
      '';
      desc = "Toggle conceal";
    }
    {
      mode = "n";
      key = "<Leader>ut";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.tabline() end
      '';
      desc = "Toggle tabline.";
    }
    {
      mode = "n";
      key = "<Leader>uu";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.url_match() end
      '';
      desc = "Toggle URL highlight.";
    }
    {
      mode = "n";
      key = "<Leader>uv";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.virtual_text() end
      '';
      desc = "Toggle virtual text.";
    }
    {
      mode = "n";
      key = "<Leader>uV";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.virtual_lines() end
      '';
      desc = "Toggle virtual lines.";
    }
    {
      mode = "n";
      key = "<Leader>uw";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.wrap() end
      '';
      desc = "Toggle wrap.";
    }
    {
      mode = "n";
      key = "<Leader>uy";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx").toggles.buffer_syntax() end
      '';
      desc = "Toggle syntax highlight..";
    }
  ];
}
