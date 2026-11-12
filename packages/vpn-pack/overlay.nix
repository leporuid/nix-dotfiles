# packages/vpn-pack/overlay.nix
# Dedicated overlay for UniFi OS aarch64-linux target environment and Tailscale patches.
{ vpnPackSrc }:
final: prev:
let
  tailscaleVersion = prev.tailscale.version;
  patchesDir = "${vpnPackSrc}/patches";

  # Patch Tailscale source code for Ubiquiti UniFi routing, fwmark, and distro detection
  tailscalePatchedSrc = prev.applyPatches {
    name = "tailscale-patched-${tailscaleVersion}";
    src = prev.tailscale.src;
    patches = [
      "${patchesDir}/001-fwmark-0x800000.patch"
      "${patchesDir}/002-ubnt-device-model.patch"
      "${patchesDir}/003-ubnt-distro-version.patch"
      "${patchesDir}/004-package-type-unifi.patch"
      "${patchesDir}/005-ubnt-forward-chain-order.patch"
      "${patchesDir}/006-ubnt-exit-route-table.patch"
    ];
  };

  # Build tags optimized for UniFi gateway firmware
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

  targetGo = final.buildPackages.go_1_27;
  buildGoModule = final.buildGoModule.override { go = targetGo; };
in
{
  inherit tailscalePatchedSrc;

  # Tailscale binary customized and stripped for UniFi Cloud Gateway (Cloud Gateway Max, Ultra, Dream Router)
  tailscale-unifi = buildGoModule {
    pname = "tailscale-unifi";
    version = tailscaleVersion;
    src = tailscalePatchedSrc;

    vendorHash = prev.tailscale.vendorHash;

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
}
