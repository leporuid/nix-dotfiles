final: prev: {
    # Use the real determinate here if you want it available!
    catppuccin-bat-theme = prev.stdenv.mkDerivation {
      pname = "catppuccin-bat-theme";
      version = "699f60f";
      src = prev.fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat";
        rev = "699f60fc8ec434574ca7451b444b880430319941";
        sha256 = "sha256-6fWoCH90IGumAmc4buLRWL0N61op+AuMNN9CAR9/OdI=";
      };
      installPhase = ''
        mkdir -p $out
        cp $src/themes/*.tmTheme $out/
      '';
      meta = {
        description = "Catppuccin themes for bat";
        homepage = "https://github.com/catppuccin/bat";
        license = prev.lib.licenses.mit;
        maintainers = [];
      };
    };
    themes = (prev.themes or {}) // {
      bat = prev.catppuccin-bat-theme;
   };
   inherit (import ./direnv.nix { inherit (prev) lib; } final prev) direnv;
}