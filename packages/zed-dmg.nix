# Native macOS DMG archive for Zed Nightly with libghostty-vt.
{
  inputs,
  pkgs,
  ...
}:
let
  zedNightly = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.zed-nightly;
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "zed-nightly-dmg";
  inherit (zedNightly) version;
  dontUnpack = true;
  __noChroot = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out" dmg
    cp -a "${zedNightly}/Applications/Zed Nightly.app" dmg/
    ln -s /Applications dmg/Applications
    /usr/bin/hdiutil create \
      -volname "Zed Nightly" \
      -srcfolder dmg \
      -ov \
      -format UDZO \
      "$out/Zed-Nightly-${zedNightly.version}.dmg"
    runHook postInstall
  '';

  meta = {
    description = "macOS DMG installer for Zed Nightly with libghostty-vt";
    homepage = "https://zed.dev";
    license = pkgs.lib.licenses.gpl3Only;
    platforms = pkgs.lib.platforms.darwin;
  };
}
