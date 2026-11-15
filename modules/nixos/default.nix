{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.hjem
    inputs.self.modules.common.vars
  ];

  nixpkgs.overlays = [
    inputs.self.overlays.default
  ];
}
