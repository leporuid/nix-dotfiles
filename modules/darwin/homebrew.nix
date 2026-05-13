{ inputs, config, ... }:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = true;
    user = config.system.primaryUser;
    autoMigrate = true;
    taps = {
      "AnInsomniacy/motrix-next" = inputs.motrix-next;
    };
  };

  homebrew = {
    enable = true;
    global.autoUpdate = false;
    onActivation = {
      upgrade = true;
      cleanup = "zap";
    };

    taps = [
      "AnInsomniacy/motrix-next"
    ];

    brews = [
    ];

    casks = map
      (name: {
        inherit name;
        greedy = true;
      }) [
	"adguard-vpn"
        "archaeology"
        "appcleaner"
        "discord"
        "bettertouchtool"
        "glance-chamburr"
        "prettyclean"w
        "raycast"
        "ghostty@tip"
        "syntax-highlight"
        "zed"
        "zen"
        "keka"
        "iina"
        "motrix-next"
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
      ];
  };
}