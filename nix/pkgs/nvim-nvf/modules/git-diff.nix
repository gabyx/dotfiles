{ lib, pkgs, ... }:
let
  act = fn: arg: lib.mkLuaInline /* lua */ ''require("diffview.actions").${fn}("${arg}")'';

  vkey = key: fn: arg: desc: [
    "n"
    key
    (act fn arg)
    { inherit desc; }
  ];
in
{
  vim.lazy = {
    plugins."diffview.nvim" = {
      package = pkgs.vimPlugins.diffview-nvim;

      setupModule = "diffview";

      lazy = true;
      cmd = [
        "DiffviewOpen"
        "DiffviewFileHistory"
      ];

      keys = [
        {
          mode = "n";
          key = "<Leader>gD";
          action = ":DiffviewOpen<cr>";
          desc = "Open Diffview.";
        }
        {
          mode = "n";
          key = "<Leader>gH";
          action = ":DiffviewFileHistory %<cr>";
          desc = "Open DiffviewFileHistory.";
        }
      ];

      setupOpts = {
        keymaps.view = [
          (vkey "<Leader>gdo" "conflict_choose" "ours" "Choose the OURS version of a conflict")
          (vkey "<Leader>gdt" "conflict_choose" "theirs" "Choose the THEIRS version of a conflict")
          (vkey "<Leader>gdb" "conflict_choose" "base" "Choose the BASE version of a conflict")
          (vkey "<Leader>gda" "conflict_choose" "all" "Choose all the versions of a conflict")
          (vkey "<Leader>gdO" "conflict_choose_all" "ours"
            "Choose the OURS version of a conflict for the whole file"
          )
          (vkey "<Leader>gdT" "conflict_choose_all" "theirs"
            "Choose the THEIRS version of a conflict for the whole file"
          )
          (vkey "<Leader>gdB" "conflict_choose_all" "base"
            "Choose the BASE version of a conflict for the whole file"
          )
          (vkey "<Leader>gdA" "conflict_choose_all" "all"
            "Choose all the versions of a conflict for the whole file"
          )
        ];
      };
    };
  };
}
