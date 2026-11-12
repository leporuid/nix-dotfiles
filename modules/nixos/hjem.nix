{
  inputs,
  ...
}:
{
  imports = [
    inputs.hjem.nixosModules.default
    ../shared/hjem.nix
  ];
}
