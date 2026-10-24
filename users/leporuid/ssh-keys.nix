# Single source of truth for authorized SSH public keys across MacBook-Pro and NixOS.
{
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaZLCaoAppOpXqJmBrB8AOCEc7zffCWU3G0P+9W4tnL"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrcoI6oOTch+FI7XVlJ5eYJaGx4ZO2noO9GcXVFMhn9"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyz8c5h0/9ejDcYYkUZ568FUw0OAQEPfRnIbbbd4xGe"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAIJNFFaMxFGkxbzGvTtFfu+DPlxtqK0NoaExRVDvCt"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBN6rDDWpOzuVy7v8foYFJdjlcNJBZpmZcwZWWhoa3dbprqJGRClVKyg1NYNj1a3D43XvxeA+Vd1AgaAQDrSIbIE= #SSH ID - @leporuid"
  ];

  keyFiles = [
    ../../hosts/MacBook-Pro/users/leporuid/id_ed25519.pub
    ../../hosts/MacBook-Pro/id_ed25519.pub
  ];
}
