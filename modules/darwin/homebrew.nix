{ inputs, config, lib, ... }:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];
  
  homebrew = {
    enable = true;
    global.brewfile = true;
    onActivation = {
      # Homebrew 6.0 (June 2026) deprecated the `brew bundle --cleanup` switch in
      # favour of `--force-cleanup` (with `--zap` for zap-style cleanup). The
      # pinned nix-darwin still emits the old `--cleanup --zap` for
      # `cleanup = "zap"` (fix pending in nix-darwin#1789), which prints a
      # deprecation warning on every activation. Until that PR lands we keep
      # `cleanup = "none"` so nix-darwin emits no cleanup flag, and pass the new
      # flags via extraFlags below — equivalent zap cleanup, no warning. Revert to
      # `cleanup = "zap"` (and drop the flags) once #1789 is merged.
      cleanup = "none";
      autoUpdate = false; # false due to this issue https://github.com/zhaofengli/nix-homebrew/issues/131
      upgrade = true;
      extraEnv = {
        HOMEBREW_NO_ENV_HINTS = "1";
        HOMEBREW_NO_ANALYTICS = "1";
        HOMEBREW_NO_ANALYTICS_MESSAGE_OUTPUT = "1";
        HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
        HOMEBREW_NO_UPDATE_REPORT_NEW = "1";
      };
      extraFlags = [ "--zap" "--force-cleanup" "--quiet" ];
    };
    taps = builtins.attrNames config.nix-homebrew.taps;

    brews = [ ];

    casks = map
      (name: {
        inherit name;
        greedy = true;
      }) [
        "archaeology"
        "appcleaner"
        "discord"
        "bettertouchtool"
        "glance-chamburr"
        "prettyclean"
        "raycast"
        "ghostty@tip"
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
        "motrix-next"
        "tailscale-app"
      ];
  };

  nix-homebrew = {
    enable = true;
    user = config.system.primaryUser;
    autoMigrate = true;
    taps = {
      "AnInsomniacy/motrix-next" = inputs.motrix-next;
    };
  };

  system.activationScripts.preActivation.text = lib.mkAfter ''
    if [ -x ${config.homebrew.prefix}/bin/brew ]; then
      sudo --user=${lib.escapeShellArg config.system.primaryUser} --set-home \
        ${config.homebrew.prefix}/bin/brew trust --tap dotenvx/brew >/dev/null 2>&1 || true
    fi
  '';

}