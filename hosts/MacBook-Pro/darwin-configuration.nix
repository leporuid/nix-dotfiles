{ pkgs, inputs, ... }:
{
  imports = [
    inputs.hjem.darwinModules.default
    ../../modules/nixos/host-shared.nix
  ];

  hjem = {
    clobberByDefault = true;
    extraModules = [
      inputs.hjem-rum.hjemModules.default
      inputs.hjem-impure.hjemModules.default
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Fish shell integration on macOS
  programs.fish = {
    enable = true;
    useBabelfish = true;
    interactiveShellInit = ''
      if test "$TERM" = "dumb"
        function fish_prompt; echo "\$ "; end
        function fish_right_prompt; end
        function fish_greeting; end
        function fish_title; end
      end
    '';
  };

  environment.pathsToLink = [
    "/share/fish/vendor_completions.d"
    "/share/fish/vendor_functions.d"
  ];

  users.users.leporuid = {
    home = "/Users/leporuid";
    shell = pkgs.fish;
  };

  hjem.users.leporuid =
    { ... }:
    {
      directory = "/Users/leporuid";
      imports = [ ../../users/leporuid/home-configuration.nix ];
    };

  system.stateVersion = 6;
}
