_: {
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
  programs.deadnix.enable = true;
  programs.statix.enable = true;
  programs.taplo.enable = true;
  programs.fish_indent.enable = true;
  programs.yamlfmt.enable = true;

  settings.global.excludes = [
    "*.age"
    "flake.lock"
    ".direnv/**"
    "*.bttpreset"
    "*.tar.gz"
  ];
}
