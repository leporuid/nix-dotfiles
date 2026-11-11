{
  pkgs,
  version ? "1.6.4",
  gitCommit ? "4549ba8",
  ...
}:

let
  vpnPackOverlay = import ./overlay.nix;

  baseTargetPkgs =
    if pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isAarch64 then
      pkgs
    else
      pkgs.pkgsCross.aarch64-multiplatform;

  targetPkgs = baseTargetPkgs.appendOverlays [ vpnPackOverlay ];

  tailscaleBin = targetPkgs.tailscale-unifi;
  tailscalePatched = targetPkgs.tailscalePatchedSrc;
  tailscaleVersion = tailscaleBin.version;

  manager = pkgs.callPackage ./manager.nix {
    inherit
      version
      tailscaleVersion
      gitCommit
      tailscalePatched
      ;
    buildGoModule = targetPkgs.buildGoModule.override {
      go = targetPkgs.buildPackages.go_1_27;
    };
  };

  deploy = pkgs.callPackage ./deploy.nix {
    inherit version tailscaleVersion gitCommit;
    inherit tailscaleBin;
    inherit (manager) managerBin;
  };
in
deploy
// {
  passthru = {
    inherit tailscalePatched tailscaleBin;
    inherit (manager) managerBin ui;
    overlay = vpnPackOverlay;
  };
}
