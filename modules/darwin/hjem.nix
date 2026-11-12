{
  inputs,
  ...
}:
{
  imports = [
    inputs.hjem.darwinModules.default
    ../shared/hjem.nix
  ];
}
