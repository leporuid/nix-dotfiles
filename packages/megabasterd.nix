{ pkgs, ... }:
pkgs.megabasterd.overrideAttrs (
  _: rec {
    version = "8.61";
    src = pkgs.fetchFromGitHub {
      owner = "tonikelope";
      repo = "megabasterd";
      tag = "v${version}";
      hash = "sha256-H3nW+phtT30nhKIBxlS3CAqVxFIWcBvStbNlnobWEiQ=";
    };
    installPhase = ''
      runHook preInstall

      makeWrapper ${pkgs.jre}/bin/java $out/bin/megabasterd \
        --add-flags "-jar $out/share/java/MegaBasterd-${version}-jar-with-dependencies.jar"

      install -Dm644 target/MegaBasterd-${version}-jar-with-dependencies.jar $out/share/java/MegaBasterd-${version}-jar-with-dependencies.jar

      runHook postInstall
    '';
  }
)
