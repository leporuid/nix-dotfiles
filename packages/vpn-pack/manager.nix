{
  pkgs,
  tailscalePatched,
  vpnPackSrc,
  buildGoModule ? (
    pkgs.pkgsCross.aarch64-multiplatform.buildGoModule.override {
      go = pkgs.pkgsCross.aarch64-multiplatform.buildPackages.go_1_27;
    }
  ),
  gitCommit ? "4549ba8",
  tailscaleVersion ? "1.104.5",
  version ? "1.6.4",
  ...
}:

let
  ui = pkgs.stdenvNoCC.mkDerivation {
    pname = "vpn-pack-ui";
    inherit version;
    src = ./ui-dist;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };

  managerSrc = pkgs.runCommand "manager-src" { } ''
    cp -r ${vpnPackSrc}/manager $out
    chmod -R u+w $out
    substituteInPlace $out/go.mod --replace-fail "../reference/tailscale" "${tailscalePatched}"
  '';

  managerBin = buildGoModule {
    pname = "vpn-pack-manager";
    inherit version;
    src = managerSrc;
    proxyVendor = true;
    vendorHash = "sha256-n328hWEKKeJbZY/NmhrFqbE6BdzlG5mb1VIw/W8u32k=";
    postPatch = ''
      mkdir -p ui/dist
      cp -r ${ui}/* ui/dist/
    '';
    ldflags = [
      "-s"
      "-w"
      ("-X unifi-tailscale/manager/config.Version=" + version)
      ("-X unifi-tailscale/manager/config.TailscaleVersion=" + tailscaleVersion)
      ("-X unifi-tailscale/manager/config.GitCommit=" + gitCommit)
      "-X unifi-tailscale/manager/config.GithubRepo=eds-ch/vpn-pack"
    ];
    hardeningDisable = [ "all" ];
    dontPatchELF = true;
    env = {
      CGO_ENABLED = 0;
      GOFLAGS = "-mod=mod";
    };
    preBuild = ''
      chmod -R u+w .
      export CGO_ENABLED=0
    '';
    postInstall = ''
      if [ -f $out/bin/manager ]; then
        mv $out/bin/manager $out/bin/vpn-pack-manager
      elif [ ! -f $out/bin/vpn-pack-manager ]; then
        for f in $out/bin/*; do
          if [ -f "$f" ]; then
            mv "$f" $out/bin/vpn-pack-manager
            break
          fi
        done
      fi
    '';
    doCheck = false;
  };
in
{
  inherit managerBin ui;
}
