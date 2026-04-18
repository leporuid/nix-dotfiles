{ pkgs, config, ... }:
let
  babelfishTranslate =
    path: name:
    pkgs.runCommand "${name}.fish" { } ''
      ${pkgs.babelfish}/bin/babelfish < ${path} > $out
    '';
in
{
  environment.etc."fish/nixos-env-preinit.fish".text = ''
    if [ -z "$__NIX_DARWIN_SET_ENVIRONMENT_DONE" ]
      source /etc/fish/setEnvironment.fish
    end
  '';
  environment.etc."fish/setEnvironment.fish".source =
    babelfishTranslate config.system.build.setEnvironment "setEnvironment";
}