{ inputs, flake, ... }:
{ config, pkgs, lib, ... }:
let
  extraTaps = [
    "aninsomniacy/homebrew-rayburst"
  ];

  tapName = t: if builtins.isString t then t else t.name;

  qualifiedTap =
    s:
    let
      parts = lib.splitString "/" s;
    in
    lib.optional (builtins.length parts >= 3) (
      lib.toLower "${builtins.elemAt parts 0}/${builtins.elemAt parts 1}"
    );

  inferredTaps = lib.concatMap
    (item: qualifiedTap (tapName item))
    (
      config.homebrew.brews
      ++ config.homebrew.casks
    );

  allTaps = lib.unique (
    map lib.toLower (
      extraTaps
      ++ builtins.attrNames config.nix-homebrew.taps
      ++ inferredTaps
    )
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
      extraFlags = [
        "--quiet"
      ];
    };

    taps = map (name: {
      inherit name;
      trusted = true;
    }) allTaps;

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
}
