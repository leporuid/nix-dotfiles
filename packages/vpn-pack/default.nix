{
  inputs,
  pkgs,
  gitCommit ? "4549ba8",
  version ? "1.6.4",
  ...
}:

let
  upstreamSrc = inputs.vpn-pack-src;

  vpnPackPatchedSrc = pkgs.applyPatches {
    name = "vpn-pack-src-${version}";
    src = upstreamSrc;
    patches = [
      ./0001-unifi-nix-packaging.patch
    ];
  };

  vpnPackOverlay = import ./overlay.nix { };

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
      gitCommit
      tailscalePatched
      tailscaleVersion
      version
      ;
    vpnPackSrc = vpnPackPatchedSrc;
    buildGoModule = targetPkgs.buildGoModule.override {
      go = targetPkgs.buildPackages.go_1_27;
    };
  };

  deploy = pkgs.callPackage ./deploy.nix {
    inherit gitCommit tailscaleVersion version;
    inherit tailscaleBin;
    inherit (manager) managerBin;
    vpnPackSrc = vpnPackPatchedSrc;
  };
in
deploy
// {
  passthru = {
    inherit tailscaleBin tailscalePatched;
    inherit (manager) managerBin ui;
    overlay = vpnPackOverlay;
    src = vpnPackPatchedSrc;
  };
}
