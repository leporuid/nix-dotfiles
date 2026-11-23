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

  hasStandalone = self ? hjemConfigurations.leporuid;
  hasDarwinHost = self ? darwinConfigurations.MacBook-Pro;

  userDirectory =
    if isDarwin then
      self.darwinConfigurations.MacBook-Pro.config.hjem.users.leporuid.directory
    else
      "/Users/leporuid";
  targetRoot = "${userDirectory}/";
  normalizeTarget = t: if lib.hasPrefix targetRoot t then lib.removePrefix targetRoot t else t;

  # Both evaluate on aarch64-darwin
  standaloneFiles =
    if isDarwin then
      let
        manifest = self.hjemConfigurations.leporuid.manifest;
      in
      map (f: {
        target = normalizeTarget f.target;
        source = if f ? source && f.source != null then toString f.source else "text:${f.text or ""}";
        clobber = f.clobber or false;
      }) manifest.files
    else
      [ ];

  hostFiles =
    if isDarwin then
      let
        user = self.darwinConfigurations.MacBook-Pro.config.hjem.users.leporuid;
        mapFiles =
          fileSet:
          map (f: {
            target = normalizeTarget f.target;
            source = if f.source != null then toString f.source else "text:${f.text or ""}";
            inherit (f) clobber;
          }) (lib.filter (f: f.enable or true) (builtins.attrValues fileSet));

        files = mapFiles user.files;
        xdgConfigFiles = mapFiles user.xdg.config.files;
        xdgCacheFiles = mapFiles user.xdg.cache.files;
        xdgDataFiles = mapFiles user.xdg.data.files;
        xdgStateFiles = mapFiles user.xdg.state.files;
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

  toKey = f: "${f.target}\t${toString f.clobber}\t${normalizeSource f.source}";
  standaloneKeys = lib.sort (a: b: a < b) (map toKey standaloneFiles);
  hostKeys = lib.sort (a: b: a < b) (map toKey hostFiles);

  missingInHost = lib.filter (k: !builtins.elem k hostKeys) standaloneKeys;
  missingInStandalone = lib.filter (k: !builtins.elem k standaloneKeys) hostKeys;
in
if isDarwin then
  assert lib.assertMsg hasStandalone
    "checks.hjem-parity: self.hjemConfigurations.leporuid is required on Darwin";
  assert lib.assertMsg hasDarwinHost
    "checks.hjem-parity: self.darwinConfigurations.MacBook-Pro is required on Darwin";
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
