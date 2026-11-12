{
  pkgs,
  tailscalePatched,
  vpnPackSrc,
  buildGoModule ? (
    pkgs.pkgsCross.aarch64-multiplatform.buildGoModule.override {
      go = pkgs.pkgsCross.aarch64-multiplatform.buildPackages.go_1_27;
    }
  ),
  version ? "1.6.4",
  tailscaleVersion ? "1.104.5",
  gitCommit ? "4549ba8",
  ...
}:

let
  ui = pkgs.stdenv.mkDerivation {
    pname = "vpn-pack-ui";
    inherit version;
    src = "${vpnPackSrc}/manager/ui";
    nativeBuildInputs = [ pkgs.bun ];

    buildPhase = ''
      if [ -d dist ] && [ -f dist/index.html ]; then
        echo "==> Using verified prebuilt UI dist"
      else
        echo "==> Building with bun"
        bun run build
      fi
    '';

    installPhase = ''
      mkdir -p $out
      cp -r dist/* $out/
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

    env.CGO_ENABLED = 0;
    env.GOFLAGS = "-mod=mod";
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
  inherit ui managerBin;
}
