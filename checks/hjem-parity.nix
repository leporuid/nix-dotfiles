# Pure-Nix parity check: verifies that the standalone Hjem manifest and
# Darwin host generation define identical target-to-source mappings.
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (inputs) self;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # Both evaluate on aarch64-darwin
  standaloneFiles =
    if isDarwin && self ? hjemConfigurations.leporuid then
      let
        manifest = self.hjemConfigurations.leporuid.manifest;
        targetRoot = "/Users/leporuid/";
        normalizeTarget = t: if lib.hasPrefix targetRoot t then lib.removePrefix targetRoot t else t;
      in
      map (f: {
        target = normalizeTarget f.target;
        source = if f ? source && f.source != null then toString f.source else "text:${f.text or ""}";
      }) manifest.files
    else
      [ ];

  hostFiles =
    if isDarwin && self ? darwinConfigurations.MacBook-Pro then
      let
        user = self.darwinConfigurations.MacBook-Pro.config.hjem.users.leporuid;
        mapFiles =
          prefix: fileSet:
          lib.mapAttrsToList (name: f: {
            target = if prefix == "" then name else "${prefix}/${name}";
            source = if f.source != null then toString f.source else "text:${f.text or ""}";
          }) (lib.filterAttrs (_: f: f.enable or true) fileSet);

        files = mapFiles "" user.files;
        xdgConfigFiles = mapFiles ".config" (user.xdg.config.files or { });
        xdgCacheFiles = mapFiles ".cache" (user.xdg.cache.files or { });
        xdgDataFiles = mapFiles ".local/share" (user.xdg.data.files or { });
        xdgStateFiles = mapFiles ".local/state" (user.xdg.state.files or { });
      in
      files ++ xdgConfigFiles ++ xdgCacheFiles ++ xdgDataFiles ++ xdgStateFiles
    else
      [ ];

  normalizeSource =
    s:
    builtins.replaceStrings
      [
        "${toString ../config}/"
        "/Users/leporuid/Developer/nix-dotfiles/config/"
      ]
      [
        "config:/"
        "config:/"
      ]
      s;

  toKey = f: "${f.target}\t${normalizeSource f.source}";
  standaloneKeys = lib.sort (a: b: a < b) (map toKey standaloneFiles);
  hostKeys = lib.sort (a: b: a < b) (map toKey hostFiles);

  missingInHost = lib.filter (k: !builtins.elem k hostKeys) standaloneKeys;
  missingInStandalone = lib.filter (k: !builtins.elem k standaloneKeys) hostKeys;
in
if isDarwin then
  assert lib.assertMsg (missingInHost == [ ] && missingInStandalone == [ ]) ''
    Hjem standalone manifest and Darwin host generation disagree!
    Missing in host: ${builtins.toJSON missingInHost}
    Missing in standalone: ${builtins.toJSON missingInStandalone}
  '';
  pkgs.runCommand "check-hjem-parity" { } ''
    touch "$out"
  ''
else
  pkgs.runCommand "check-hjem-parity-skipped" { } ''
    touch "$out"
  ''
