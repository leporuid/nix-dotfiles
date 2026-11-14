# lib/hjem.nix — Hjem & Hjem-Rum program factory helpers
_: {
  # Factory to construct a moni-dz / hjem-rum style typed program module
  mkProgramModule =
    {
      name,
      defaultEnable ? false,
      defaultPackage ? null,
      description ? "${name} configuration",
    }:
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.programs.${name};
      pkg = if defaultPackage != null then defaultPackage pkgs else pkgs.${name};
    in
    {
      options.my.programs.${name} = {
        enable = lib.mkEnableOption description // {
          default = defaultEnable;
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkg;
          description = "The package to use for ${name}.";
        };
      };

      config = lib.mkIf cfg.enable {
        packages = [ cfg.package ];
      };
    };
}
