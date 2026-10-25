{ flake, ... }:
{
  hostname = "nixos";
  username = "leporuid";
  sshKeys = [
    # My iPhone, blink terminal
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGr7upNdIAAtGkiQaUkCaj5g6QW843fL3bbsJyP/0tAB"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrcoI6oOTch+FI7XVlJ5eYJaGx4ZO2noO9GcXVFMhn9"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyz8c5h0/9ejDcYYkUZ568FUw0OAQEPfRnIbbbd4xGe"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAIJNFFaMxFGkxbzGvTtFfu+DPlxtqK0NoaExRVDvCt"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBN6rDDWpOzuVy7v8foYFJdjlcNJBZpmZcwZWWhoa3dbprqJGRClVKyg1NYNj1a3D43XvxeA+Vd1AgaAQDrSIbIE= #SSH ID - @leporuid"
  ];
  keyFiles = [
    "${flake}/hosts/MacBook-Pro/users/leporuid/id_ed25519.pub"
    "${flake}/hosts/MacBook-Pro/id_ed25519.pub"
    "${flake}/id_ed25519.pub"
  ];
  locale = "en_US.UTF-8";
  timezone = "Asia/Taipei";
}
