{ flake, ... }:
{
  # Inherit generic user configuration defined under users/me/
  imports = [ "${flake}/users/me/home-configuration.nix" ];
}
