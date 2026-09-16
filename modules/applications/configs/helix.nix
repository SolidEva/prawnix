{ pkgs, lib, ... }:
let
  helix-overlay = final: prev: {
    helix = pkgs.symlinkJoin {
      name = "helix";
      paths = [ prev.helix ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/hx --set XDG_CONFIG_HOME "/etc/xdg/"
      '';
    };
  };
in
{

  nixpkgs.overlays = [ helix-overlay ];
  environment.systemPackages = [
    pkgs.helix
    pkgs.typos-lsp
    pkgs.yaml-language-server
  ];

  environment.variables.EDITOR = "hx";
  environment.variables.VISUAL = "hx";

  environment.etc = {
    "xdg/helix/config.toml".text = ''
      # also consider "flatwhite" or "kaolin-light"
      theme = "rose_pine_dawn"

      # settings at https://docs.helix-editor.com/master/editor.html
      [editor]
      mouse = true
      line-number = "relative"
      end-of-line-diagnostics = "hint"
      true-color = true
      bufferline = "always"
      color-modes = true
      popup-border = "all"

      [editor.cursor-shape]
      insert = "bar"
      normal = "block"
      select = "underline"

      [editor.file-picker]
      hidden = false

      [editor.soft-wrap]
      enable = true

      [editor.lsp]
      display-inlay-hints = true

      # not yet available in 25.07.1, which is the latest release
      # auto-document-highlight = true

      [editor.inline-diagnostics]
      cursor-line = "warning"
      other-lines = "warning"

      [keys.normal]
      # vim visual line select
      V = ["select_mode", "extend_to_line_bounds"]
      # aka "ge" by default
      G = "goto_file_end"
    '';
  };

  environment.etc = {
    "xdg/helix/languages.toml".text = ''
      [language-server.typos]
      # typos-lsp must be on your PATH, or otherwise change this to an absolute path to typos-lsp
      command = "typos-lsp"
      # Logging level of the language server. Defaults to error.
      # Run with helix -v to output LSP logs to the editor log (:log-open)
      environment = {"RUST_LOG" = "typos_lsp=error"}
      # How typos are rendered in the editor, can be one of an Error, Warning, Info or Hint.
      # Defaults to Info.
      config.diagnosticSeverity = "Warning"

      [language-server.nix]
      command = "nixd"

      [[language]]
      name = "nix"
      formatter = { command = "nixfmt" }

      [[language]]
      name = "markdown"
      language-servers = [ "marksman", "markdown-oxide", "rumdl", "typos"]
    '';
  };

}
