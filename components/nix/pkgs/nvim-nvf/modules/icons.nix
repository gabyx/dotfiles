{ lib, ... }:
let
  defaultIcons = {
    ActiveLSP = "";
    ActiveTS = "";
    ArrowLeft = "";
    ArrowRight = "";
    Browse = "󰜏";
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
    Exit = "󰈆 ";
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
    GitHunk = "";
    GitBlame = "󰈷";
    GitDiff = "";
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
    GitStash = "󰸧";
    Indent = "";
    LineNumber = "";
    List = "";
    LSPLoading1 = "";
    LSPLoading2 = "󰀚";
    LSPLoading3 = "";
    Macro = "󰡱";
    Mark = "★";
    Move = "";
    MacroRecording = "";
    Navigation = "󱣱";
    Package = "󰏖";
    Paste = "󰅌";
    Reset = "󰗨";
    Refresh = "";
    Toggle = " ";
    Undo = "";
    Search = "";
    Selected = "❯";
    Session = "󱂬";
    Sort = "󰒺";
    Spellcheck = "󰓆";
    Status = "󱖫";
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
