{ pkgs, ... }:
pkgs.writers.writePython3Bin "oci-import-image" {
  libraries = with pkgs.python3Packages; [
    oci
    requests
  ];
  flakeIgnore = [
    "E501"
    "F541"
  ];
} (builtins.readFile ./oci-import-image.py)
