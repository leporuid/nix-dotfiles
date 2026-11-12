{ pkgs, ... }:

pkgs.unxip.overrideAttrs (_: {
  src = pkgs.fetchFromGitHub {
    owner = "ranvel";
    repo = "unxip";
    rev = "libunxip-patches";
    hash = "sha256-+DYqb4Y2jqWEMungO+rE1UzMXLuAWAzsx6s0mbtOkR4=";
  };
})
