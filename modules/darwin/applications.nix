{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.darwin.applications;
  extraTaps = [
    "aninsomniacy/homebrew-rayburst"
  ];
in
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.mac-app-util.darwinModules.default
    inputs.nixcord.darwinModules.nixcord
  ];

  options.my.darwin.applications = {
    enable = lib.mkEnableOption "Darwin applications, nixcord, and Homebrew management" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      # =========================================================================
      # 1. System Packages & Applications
      # =========================================================================
      systemPackages = [
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.n-m3u8dl-re
      ];
      variables = {
        HOMEBREW_NO_AUTO_UPDATE = "1";
        HOMEBREW_NO_ENV_HINTS = "1";
        HOMEBREW_NO_ANALYTICS = "1";
      };
    };
    # =========================================================================
    # 3. Discord & Vencord Configuration (nixcord)
    # =========================================================================
    programs.nixcord = {
      enable = true;
      user = config.system.primaryUser;
      discord = {
        enable = true;
        vencord.enable = true;
      };

      config = {
        useQuickCss = true;
        themeLinks = [
          "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css"
        ];
        plugins = {
          alwaysTrust.enable = true;
          betterFolders.enable = true;
          betterSettings.enable = true;
          callTimer.enable = true;
          copyUserUrls.enable = true;
          directFileDownload.enable = true;
          experiments.enable = true;
          fakeNitro.enable = true;
          messageLogger.enable = true;
          openInApp.enable = true;
          pictureInPicture.enable = true;
          previewMessage.enable = true;
          relationshipNotifier.enable = true;
          translate.enable = true;
          volumeBooster.enable = true;
        };
      };
    };
    system = {
      # =========================================================================
      # 4. Application Trampolines & Native Clones (Activation Scripts)
      # =========================================================================
      activationScripts = {
        applications.text = lib.mkForce "";

        postActivation.text = ''
          rm -rf "/Applications/Nix Apps"

          ${inputs.self.lib.mkAppCloneScript "${
            inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.n-m3u8dl-re
          }/Applications/M3U8DLProtocol.app"}

          ${inputs.self.lib.mkAppCloneScript "${
            config.programs.nixcord.discord.finalPackage or config.programs.nixcord.finalPackage.discord
              or config.programs.nixcord.discord.package
          }/Applications/Discord.app"}

          userHome="/Users/${config.system.primaryUser}"
          if [ -d "$userHome/.config/Vencord" ] && [ ! -e "$userHome/Library/Application Support/Vencord" ]; then
            mkdir -p "$userHome/Library/Application Support"
            ln -sfn "$userHome/.config/Vencord" "$userHome/Library/Application Support/Vencord"
            chown -h "${config.system.primaryUser}" "$userHome/Library/Application Support/Vencord" 2>/dev/null || true
          fi
        '';
      };
      # =========================================================================
      # 5. Homebrew & Casks Declarative Management
      # =========================================================================
      activationScripts.homebrew.text = lib.mkBefore ''
        set +e
      '';
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
        cleanup = "none";
        extraFlags = [
          "--quiet"
        ];
      };

      taps = map (name: {
        inherit name;
        trusted = true;
      }) (lib.unique (extraTaps ++ builtins.attrNames config.nix-homebrew.taps));

      casks = [
        "adguard-vpn"
        "aninsomniacy/rayburst/rayburst"
        "appcleaner"
        "archaeology"
        "bettertouchtool"
        "font-maple-mono-nf"
        "font-maple-mono-nf-cn"
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
      enableFishIntegration = false;
      enableZshIntegration = false;
      enableBashIntegration = false;
      taps = {
        "aninsomniacy/homebrew-rayburst" = inputs.homebrew-rayburst;
      };
    };
  };
}
