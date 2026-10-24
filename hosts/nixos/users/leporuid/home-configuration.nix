{
  flake,
  ...
}:
{
  home.stateVersion = "26.11";

  imports = [
    "${flake}/users/leporuid/cloud-configuration.nix"
  ];
}
