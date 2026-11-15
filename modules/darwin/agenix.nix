{
  inputs,
  pkgs,
  vars,
  ...
}:
{
  imports = [
    inputs.agenix.darwinModules.default
  ];
  age = {
    ageBin = "${pkgs.age}/bin/age";
    identityPaths = [
      "${vars.homeDirectory}/.ssh/id_ed25519"
    ];
    secrets = {
      tailscale-authkey = {
        file = "${inputs.nix-secrets}/hosts/MacBook-Pro/tailscale-authkey.age";
        owner = vars.username;
        group = "staff";
        mode = "0400";
      };

      flakehub = {
        file = "${inputs.nix-secrets}/hosts/MacBook-Pro/flakehub.age";
        owner = vars.username;
        group = "staff";
        mode = "0400";
      };
    };
  };
}
