{ inputs, config, lib, ... }:

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
      autoUpdate = true;
      cleanup = "none";
      upgrade = true;
      extraFlags = [ "--zap" "--force-cleanup" "--quiet" ];
    };

    taps = lib.map 
     (name: {
  	inherit name;
 	trusted = true;
     }) (builtins.attrNames config.nix-homebrew.taps);

    brews = [ ];

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

  system.activationScripts.preActivation.text = lib.mkAfter ''
   if [ -x ${config.homebrew.prefix}/bin/brew ]; then
      # shellcheck disable=SC2043
      for tap in ${lib.escapeShellArgs (builtins.map (t: t.name) config.homebrew.taps)}; do
        sudo --user=${lib.escapeShellArg config.system.primaryUser} --set-home \
          ${config.homebrew.prefix}/bin/brew trust "$tap" >/dev/null 2>&1 || true
      done
    fi
  '';
}