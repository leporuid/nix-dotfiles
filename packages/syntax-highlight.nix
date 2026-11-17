{ lib, pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "syntax-highlight";
  version = "2.2.1";

  src = pkgs.fetchurl {
    url = "https://github.com/amichaelyu/SourceCodeSyntaxHighlight/releases/download/v${finalAttrs.version}/Syntax-Highlight-${finalAttrs.version}-arm64.zip";
    hash = "sha256-s+Xrzt7n3JiFbR/8zeq0hRtRpaSn+5ryOpCqX8kSGcc=";
  };

  nativeBuildInputs = [
    pkgs.unzip
  ];

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -a "Syntax Highlight.app" "$out/Applications/"
    ln -s "../Applications/Syntax Highlight.app/Contents/Resources/syntax_highlight_cli" \
      "$out/bin/syntax_highlight_cli"

    runHook postInstall
  '';

  meta = {
    description = "Quick Look extension for source code, Markdown, and LaTeX";
    homepage = "https://github.com/amichaelyu/SourceCodeSyntaxHighlight";
    license = lib.licenses.gpl3Plus;
    mainProgram = "syntax_highlight_cli";
    platforms = [ "aarch64-darwin" ];
  };
})
