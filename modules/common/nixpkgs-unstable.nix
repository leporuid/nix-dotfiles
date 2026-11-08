{
  inputs,
  pkgs,
  ...
}:
{
  _module.args.pkgs' = import inputs.determinate.inputs.nixpkgs {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
    inherit (pkgs) overlays;
  };
}
