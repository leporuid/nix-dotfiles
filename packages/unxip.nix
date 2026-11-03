{ pkgs, ... }:
with pkgs;
unxip.overrideAttrs (oldAttrs: {
  src = pkgs.fetchFromGitHub {
    owner = "ranvel";
    repo = "unxip";
    rev = "libunxip-patches";
    hash = "sha256-jFChmKUA7+obHkZnd7ZpqeejZfeA+gTUELo1iYeFMFo";
  };
})
