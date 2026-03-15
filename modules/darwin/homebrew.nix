{ inputs, ... }:
let
  mkGreedy = caskName: {
    name = caskName;
    greedy = true;
  };
in
{
  imports = [
            inputs.nix-homebrew.darwinModules.nix-homebrew
          ];

  homebrew = {
            enable = true;
            global.autoUpdate = false;
            onActivation = {
              upgrade = true;
              # 'zap': uninstalls all formulae (and related files) not listed here.
              cleanup = "zap";
            };


    brews = [
       "unxip"
       "mas"
    ];
    casks = map mkGreedy [
      "archaeology"
      "appcleaner"
      "discord"
      "bettertouchtool"
      "glance-chamburr"
      "prettyclean"
      "qlvideo"
      "raycast"
      "ghostty@tip"
      "syntax-highlight"
      "zed"
      "keka"
      "iina"
      "adguard-vpn"
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
