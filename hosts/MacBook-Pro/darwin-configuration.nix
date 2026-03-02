{
  inputs,
  pkgs,
  lib,
  flake,
  config,
  ...
}:let
  inherit (inputs) self;
in
{
  imports = [
    inputs.determinate.darwinModules.default
    inputs.self.darwinModules.system-defaults
    inputs.self.darwinModules.fish-environment
    

    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.self.darwinModules.homebrew
    inputs.self.modules.common.nix-settings
      ];
 
  users.users.leporuid = {
    description = "Yu-Min Peng";
    home = "/Users/leporuid";
    openssh.authorizedKeys.keys = [
      # My iPhone, blink terminal
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaZLCaoAppOpXqJmBrB8AOCEc7zffCWU3G0P+9W4tnL"

      # My iPad, blink terminal
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrcoI6oOTch+FI7XVlJ5eYJaGx4ZO2noO9GcXVFMhn9"
    ];
    openssh.authorizedKeys.keyFiles = [
      # Allows both my user account and system root to SSH into the leporuid account.
      # This is so I can use macmini as a remote builder to offload some work from
      # the more thermally constrained laptop, but unfortunately because the laptop
      # isn't managed with nix-darwin, I have to manually configure the builder :(
      # Allows me to SSH into myself, which is useful sometimes
      "${flake}/hosts/MacBook-Pro/users/leporuid/id_ed25519.pub"
      "${flake}/hosts/MacBook-Pro/id_ed25519.pub"
    ];
  };
  
  services.tailscale.enable = true;
  services.openssh.enable = true;
  environment.etc."ssh/sshd_config.d/999-disable-password-auth.conf".text = ''
    PermitRootLogin no
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    UsePAM no
  '';

  # This needs to be reapplied after each system update. My Fish configuration
  # will warn about this if it detects the line it adds to sudo_local is absent.
  # touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

 
  networking.hostName = "MacBook-Pro";

  system.stateVersion = 6;
  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.primaryUser = "leporuid";
  
  home-manager.backupFileExtension = "hm-backup";

  nix-homebrew.enable = true;
  # A user needs to own the prefix, so we'll make it my account
  nix-homebrew.user = "${config.system.primaryUser}";

  environment.systemPackages = [
    pkgs.fish
    pkgs.mosh
  ];

 # Not sure about adding in vendor_conf.d because tools can just dump their init into it,
  # and because it will be included in a directory in $NIX_PROFILES, therefore
  # also $XDG_DATA_DIRS, it will be sourced during startup. This is probably fine, but
  # I want total control over what runs in my fish config.
  environment.pathsToLink = [
    # "/share/fish/vendor_conf.d"
    "/share/fish/vendor_completions.d"
    "/share/fish/vendor_functions.d"
  ];

 nixpkgs.hostPlatform = "aarch64-darwin";
 
 nix.enable = false;
 determinateNix = {
    customSettings = {
      eval-cores = 0;
      trusted-users = [
        "${config.system.primaryUser}"
      ];
    };
  };
 
 nix.nixPath = lib.mkForce [
    "nixpkgs=${inputs.nixpkgs}"
    "home-manager=${inputs.home-manager}"
  ];

 nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
 nix.settings.trusted-users = [ "@admin" ];
 nix.channel.enable = false;
 ids.gids.nixbld = 30000;
 environment.etc."nix-host".text = "MacBook-Pro";
}