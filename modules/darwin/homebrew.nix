{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
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
      no_quarantine = true;
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
      "aninsomniacy/rayburst/rayburst"
      "appcleaner"
      "arc"
      "archaeology"
      "bettertouchtool"
      "font-maple-mono"
      "font-maple-mono-cn"
      "font-maple-mono-nf"
      "font-maple-mono-nf-cn"
      "font-maple-mono-normal"
      "font-maple-mono-normal-cn"
      "font-maple-mono-normal-nf"
      "font-maple-mono-normal-nf-cn"
      "font-sf-mono"
      "font-sf-pro"
      "font-sketchybar-app-font"
      "ghostty"
      "iina"
      "keka"
      "prettyclean"
      "raycast"
      "sf-symbols"
      "suspicious-package"
      "syntax-highlight"
      "tailscale-app"
      "zed"
      "zen"
    ];
  };

  nix-homebrew = {
    enable = true;
    user = config.system.primaryUser;
    autoMigrate = true;
    mutableTaps = true;
    taps = {
      "aninsomniacy/homebrew-rayburst" = inputs.homebrew-rayburst;
    };
  };
}
