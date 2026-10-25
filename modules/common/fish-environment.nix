{
  pkgs,
  config,
  lib,
  ...
}:

let
  fishEnvironment = pkgs.runCommand "fish-system-environment.fish" { } ''
    ${pkgs.babelfish}/bin/babelfish \
      < ${config.system.build.setEnvironment} \
      > "$out"
  '';
in
{
  config = lib.mkIf config.programs.fish.enable {
    environment.etc."fish/conf.d/00-system-environment.fish".source =
      fishEnvironment;
  };
}