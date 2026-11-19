{
  inputs,
  pkgs,
  gitCommit ? (
    inputs.vpn-pack-src.shortRev or (builtins.substring 0 7 (inputs.vpn-pack-src.rev or "4549ba8"))
  ),
  version ? (pkgs.lib.strings.trim (builtins.readFile "${inputs.vpn-pack-src}/VERSION")),
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
