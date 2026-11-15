{ inputs, ... }:
{
  imports = [
    inputs.self.darwinModules.hjem
    inputs.self.darwinModules.agenix
    inputs.self.modules.common.vars
    inputs.self.darwinModules.system-defaults
    inputs.self.darwinModules.applications
  ];
  nixpkgs.overlays = [ inputs.self.overlays.default ];
}
