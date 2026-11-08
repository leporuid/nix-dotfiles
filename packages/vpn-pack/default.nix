{
  pkgs,
  version ? "1.6.4",
  tailscaleVersion ? pkgs.tailscale.version,
  gitCommit ? "4549ba8",
  ...
}:

let
  tailscaleSrc = pkgs.tailscale.src;
  tailscalePatched = pkgs.applyPatches {
    name = "tailscale-patched-${tailscaleVersion}";
    src = tailscaleSrc;
    patches = [
      ./patches/001-fwmark-0x800000.patch
      ./patches/002-ubnt-device-model.patch
      ./patches/003-ubnt-distro-version.patch
      ./patches/004-package-type-unifi.patch
      ./patches/005-ubnt-forward-chain-order.patch
      ./patches/006-ubnt-exit-route-table.patch
    ];
  };

  tailscaleBuildTags = [
    "ts_package_unifi"
    "ts_omit_ace"
    "ts_omit_acme"
    "ts_omit_appconnectors"
    "ts_omit_aws"
    "ts_omit_bird"
    "ts_omit_capture"
    "ts_omit_captiveportal"
    "ts_omit_clientupdate"
    "ts_omit_cloud"
    "ts_omit_completion"
    "ts_omit_dbus"
    "ts_omit_debugeventbus"
    "ts_omit_debugportmapper"
    "ts_omit_desktop_sessions"
    "ts_omit_drive"
    "ts_omit_hujsonconf"
    "ts_omit_identityfederation"
    "ts_omit_kube"
    "ts_omit_lazywg"
    "ts_omit_linuxdnsfight"
    "ts_omit_netlog"
    "ts_omit_networkmanager"
    "ts_omit_oauthkey"
    "ts_omit_outboundproxy"
    "ts_omit_portlist"
    "ts_omit_posture"
    "ts_omit_qrcodes"
    "ts_omit_resolved"
    "ts_omit_serve"
    "ts_omit_synology"
    "ts_omit_syspolicy"
    "ts_omit_systray"
    "ts_omit_taildrop"
    "ts_omit_tap"
    "ts_omit_tpm"
    "ts_omit_useproxy"
    "ts_omit_wakeonlan"
    "ts_omit_webclient"
  ];
  targetPkgs =
    if pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isAarch64 then
      pkgs
    else
      pkgs.pkgsCross.aarch64-multiplatform;

  targetGo = targetPkgs.buildPackages.go_1_27;
  buildGoModule = targetPkgs.buildGoModule.override { go = targetGo; };

  tailscaleBin = buildGoModule {
    pname = "tailscale-unifi";
    version = tailscaleVersion;
    src = tailscalePatched;

    vendorHash = pkgs.tailscale.vendorHash;

    subPackages = [
      "cmd/tailscale"
      "cmd/tailscaled"
    ];

    tags = tailscaleBuildTags;

    ldflags = [
      "-s"
      "-w"
    ];

    hardeningDisable = [ "all" ];
    dontPatchELF = true;

    preBuild = ''
      export CGO_ENABLED=0
    '';

    env.CGO_ENABLED = 0;
    doCheck = false;
  };

  manager = pkgs.callPackage ./manager.nix {
    inherit
      version
      tailscaleVersion
      gitCommit
      tailscalePatched
      buildGoModule
      ;
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
  };
}
