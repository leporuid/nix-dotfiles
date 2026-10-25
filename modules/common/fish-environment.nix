{ ... }:
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
    programs.fish.shellInit = ''
      source ${fishEnvironment}
    '';
  };
}
