{ pkgs, ... }:

pkgs.unxip.overrideAttrs (_: {
  src = pkgs.fetchFromGitHub {
    owner = "ranvel";
    repo = "unxip";
    rev = "3182d078f302399700d0d4941dd555bbb3c6af04";
    hash = "sha256-jFChmKUA7+obHkZnd7ZpqeejZfeA+gTUELo1iYeFMFo=";
  };
})
