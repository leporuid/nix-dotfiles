{ inputs, ... }:
{ config, pkgs, lib, ... }:
let
  extraTaps = [
    "aninsomniacy/homebrew-rayburst"
  ];
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

    caskArgs = {
      no_quarantine = true; # 免除首次開啟 Gatekeeper 警示
    };

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
      extraFlags = [
        "--quiet"
      ];
    };

    taps = map (name: { inherit name; trusted = true; }) (
      lib.unique (extraTaps ++ builtins.attrNames config.nix-homebrew.taps)
    );

    casks = [
      "adguard-vpn"
      "archaeology"
      "appcleaner"
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
    mutableTaps = false;
    taps = {
      "aninsomniacy/homebrew-rayburst" = inputs.homebrew-rayburst;
    };
  };
}
