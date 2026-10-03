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
      mkdir -p $out/themes
      cp $src/themes/*.tmTheme $out/themes/
    '';
    meta = {
      description = "Catppuccin themes for bat";
      homepage = "https://github.com/catppuccin/bat";
      license = prev.lib.licenses.mit;
      maintainers = [];
    };
  };

  themes = (prev.themes or {}) // {
    # FIX: Changed `prev` to `final` to reference the package defined above
    bat = final.catppuccin-bat-theme;
  };
  
  n-m3u8dl-re = prev.n-m3u8dl-re.overrideAttrs (old: {
    version = "unstable-main";

    src = prev.fetchFromGitHub {
      owner = "nilaoda";
      repo = "N_m3u8DL-RE";
      rev = "main";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    nugetDeps = ./n-m3u8dl-re-deps.nix; 
  });

  megabasterd = prev.megabasterd.overrideAttrs (old: rec {
    version = "8.61"; 
    src = final.fetchFromGitHub {
      owner = "tonikelope";
      repo = "megabasterd";
      tag = "v${version}";
      hash = "sha256-H3nW+phtT30nhKIBxlS3CAqVxFIWcBvStbNlnobWEiQ="; 
    };
    installPhase = ''
      runHook preInstall

      makeWrapper ${final.jre}/bin/java $out/bin/megabasterd \
        --add-flags "-jar $out/share/java/MegaBasterd-${version}-jar-with-dependencies.jar"

      install -Dm644 target/MegaBasterd-${version}-jar-with-dependencies.jar $out/share/java/MegaBasterd-${version}-jar-with-dependencies.jar

      runHook postInstall
    '';
  });
}