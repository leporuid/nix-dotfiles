let
  system = builtins.readFile /etc/ssh/ssh_host_ed25519_key.pub;
  leporuid-MacBook-Pro  = builtins.readFile ./hosts/MacBook-Pro/users/leporuid/id_ed25519.pub;
  nixos = "age1pl2c35vsgguthg3p32lwtlndmh8d2c5ha90t7ssh87lny7ptzegqaj3cvn";

  leporuid = [
    leporuid-MacBook-Pro
  ];
in {
  "hosts/MacBook-Pro/tailscale-authkey.age".publicKeys = [ system ] ++ leporuid;
  "hosts/MacBook-Pro/flakehub.age".publicKeys = [ system ] ++ leporuid;

  # 確保舊有的 tailzero*.age 檔案已經複製到 nix-dotfiles/secrets/ 下
  "hosts/nixos/tailzero-invite.age".publicKeys = [ nixos ] ++ leporuid;
  "hosts/nixos/tailzero-token.age".publicKeys = [ nixos ] ++ leporuid;
}