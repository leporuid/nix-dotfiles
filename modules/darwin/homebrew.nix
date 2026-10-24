{
  inputs,
  config,
  lib,
  ...
}:

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
          "orion"
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
}
