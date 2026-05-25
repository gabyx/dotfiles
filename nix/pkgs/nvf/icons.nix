{ lib, ... }:
let
  defaultIcons = {
    ActiveLSP = "";
    ActiveTS = "";
    ArrowLeft = "";
    ArrowRight = "";
    Bookmarks = "";
    BufferClose = "󰅖";
    DapBreakpoint = "";
    DapBreakpointCondition = "";
    DapBreakpointRejected = "";
    DapLogPoint = "󰛿";
    DapStopped = "󰁕";
    Debugger = "";
    DefaultFile = "󰈙";
    Diagnostic = "󰒡";
    DiagnosticError = "";
    DiagnosticHint = "󰌵";
    DiagnosticInfo = "󰋼";
    DiagnosticWarn = "";
    Ellipsis = "…";
    Environment = "";
    FileNew = "";
    FileModified = "";
    FileReadOnly = "";
    FoldClosed = "";
    FoldOpened = "";
    FoldSeparator = " ";
    FolderClosed = "";
    FolderEmpty = "";
    FolderOpen = "";
    Git = "󰊢";
    GitAdd = "";
    GitBranch = "";
    GitChange = "";
    GitConflict = "";
    GitDelete = "";
    GitIgnored = "◌";
    GitRenamed = "➜";
    GitSign = "▎";
    GitStaged = "✓";
    GitUnstaged = "✗";
    GitUntracked = "★";
    List = "";
    LSPLoading1 = "";
    LSPLoading2 = "󰀚";
    LSPLoading3 = "";
    MacroRecording = "";
    Navigation = "󱣱";
    Package = "󰏖";
    Paste = "󰅌";
    Refresh = "";
    Search = "";
    Selected = "❯";
    Session = "󱂬";
    Sort = "󰒺";
    Spellcheck = "󰓆";
    Tab = "󰓩";
    TabClose = "󰅙";
    Terminal = "";
    Window = "";
    WordFile = "󰈭";
  };
in
{
  options.gabyx = {
    icons = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = defaultIcons;
      description = ''
        All icons used.
      '';
    };
  };
}
