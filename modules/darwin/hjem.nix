{
  inputs,
  ...
}:
{
  imports = [
    inputs.hjem.darwinModules.default
    inputs.self.modules.common.hjem
  ];
}
