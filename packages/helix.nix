{ pkgs, flake }:
pkgs.writeShellScriptBin "hx" ''
  export PATH=${pkgs.my.ccase}/bin:$PATH
  exec ${pkgs.my.helix}/bin/hx -c ${flake}/config/helix/config.toml "$@"
''