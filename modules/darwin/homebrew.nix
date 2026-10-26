{ inputs, ... }:
{
  config,
  lib,
  ...
}:
let
  tapName = t: if builtins.isString t then t else t.name;

  qualifiedTap =
    s:
    let
      parts = lib.splitString "/" s;
    in
    lib.optional (builtins.length parts >= 3) (
      lib.toLower "${builtins.elemAt parts 0}/${builtins.elemAt parts 1}"
    );

  trustedTaps = lib.unique (
    (map (t: lib.toLower (tapName t)) config.homebrew.taps)
    ++ lib.concatMap (b: qualifiedTap (tapName b)) config.homebrew.brews
    ++ lib.concatMap (c: qualifiedTap (tapName c)) config.homebrew.casks
  );
in
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  environment.variables = {
    HOMEBREW_NO_AUTO_UPDATE = "1";
    HOMEBREW_NO_ENV_HINTS = "1";
  };

  homebrew = {
    enable = true;
    global.brewfile = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
      extraEnv = {
        HOMEBREW_NO_UPDATE_REPORT_NEW = "1";
        HOMEBREW_NO_ENV_HINTS = "1";
        HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
      };
      extraFlags = [
        "--quiet"
      ];
    };

    taps = lib.map (name: {
      inherit name;
      trusted = true;
    }) (builtins.attrNames config.nix-homebrew.taps);

    brews = [ ];

    casks =
      map
        (name: {
          inherit name;
          greedy = true;
        })
        [
          "adguard-vpn"
          "archaeology"
          "appcleaner"
          "discord"
          "bettertouchtool"
          "prettyclean"
          "raycast"
          "ghostty"
          "syntax-highlight"
          "zed"
          "zen"
          "keka"
          "iina"
          "suspicious-package"
          "sf-symbols"
          "font-maple-mono"
          "font-maple-mono-nf"
          "font-maple-mono-cn"
          "font-maple-mono-nf-cn"
          "font-maple-mono-normal"
          "font-maple-mono-normal-nf"
          "font-maple-mono-normal-cn"
          "font-maple-mono-normal-nf-cn"
          "font-sf-mono"
          "font-sf-pro"
          "font-sketchybar-app-font"
          "arc"
          "aninsomniacy/rayburst/rayburst"
          "tailscale-app"
        ];
  };

  nix-homebrew = {
    enable = true;
    user = config.system.primaryUser;
    autoMigrate = true;
    taps = {
      "aninsomniacy/homebrew-rayburst" = inputs.homebrew-rayburst;
    };
  };

  # Automatically trust declared third-party taps before brew bundle runs.
  system.activationScripts.preActivation.text = lib.mkAfter ''
    if [ -x ${config.homebrew.prefix}/bin/brew ]; then
      for tap in ${lib.escapeShellArgs trustedTaps}; do
        sudo --user=${lib.escapeShellArg config.system.primaryUser} --set-home \
          ${config.homebrew.prefix}/bin/brew trust "$tap" >/dev/null 2>&1 || true
      done
    fi
  '';
}
