{
  inputs,
  ...
}:
{
  imports = [
    inputs.hjem.nixosModules.default
    inputs.self.modules.common.hjem
  ];
}
