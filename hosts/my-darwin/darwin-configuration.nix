{ pkgs, self, inputs, ... }:
{
  imports = [ self.nixosModules.host-shared ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.me.home = "/Users/me";

  system.stateVersion = 6;
}
