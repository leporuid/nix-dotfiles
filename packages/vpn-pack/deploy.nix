{
  lib ? pkgs.lib,
  pkgs,
  managerBin,
  tailscaleBin,
  vpnPackSrc,
  gitCommit ? "4549ba8",
  tailscaleVersion ? "1.104.5",
  version ? "1.6.4",
  ...
}:

let
  tailscaledService = pkgs.writeText "tailscaled.service" ''
    [Unit]
    Description=Tailscale node agent (UniFi)
    Documentation=https://tailscale.com/kb/
    Wants=network-pre.target
    After=network-pre.target ubios-udapi-server.service

    [Service]
    EnvironmentFile=/persistent/vpn-pack/tailscaled.defaults
    ExecStart=/persistent/vpn-pack/bin/tailscaled \
      --state=/persistent/vpn-pack/state/tailscaled.state \
      --statedir=/persistent/vpn-pack/state \
      --socket=/run/tailscale/tailscaled.sock \
      --port=''${PORT} $FLAGS
    ExecStopPost=/persistent/vpn-pack/bin/tailscaled --cleanup

    Restart=on-failure

    RuntimeDirectory=tailscale
    RuntimeDirectoryMode=0755
    Type=notify

    [Install]
    WantedBy=multi-user.target
  '';

  tailscaledDefaults = pkgs.writeText "tailscaled.defaults" ''
    # Tailscale daemon configuration for UniFi devices
    PORT="41641"
    FLAGS=""
  '';

  managerService = pkgs.writeText "vpn-pack-manager.service" ''
    [Unit]
    Description=VPN Pack Manager (UniFi)
    After=tailscaled.service ubios-udapi-server.service unifi-core.service vpn-pack-manager.socket
    Wants=tailscaled.service
    Requires=vpn-pack-manager.socket

    [Service]
    ExecStart=/persistent/vpn-pack/bin/vpn-pack-manager \
        --socket=/run/tailscale/tailscaled.sock
    Restart=on-failure
    RestartSec=5
    RestartPreventExitStatus=78

    # Hardening (SEC-B2)
    CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW
    AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW
    NoNewPrivileges=yes
    ProtectSystem=strict
    ReadWritePaths=/persistent/vpn-pack /run/vpn-pack /proc/nf_dpi /data/unifi-core/config/http
    ProtectHome=yes
    PrivateTmp=yes
    PrivateDevices=no
    ProtectKernelTunables=yes
    ProtectKernelModules=yes
    ProtectControlGroups=yes
    RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6 AF_NETLINK
    RestrictNamespaces=yes
    RestrictSUIDSGID=yes
    LockPersonality=yes
    MemoryDenyWriteExecute=yes
    SystemCallFilter=@system-service
    SystemCallArchitectures=native

    [Install]
    WantedBy=multi-user.target
  '';

  managerSocket = pkgs.writeText "vpn-pack-manager.socket" ''
    [Unit]
    Description=VPN Pack Manager API socket

    [Socket]
    ListenStream=/run/vpn-pack/manager.sock
    SocketUser=root
    SocketGroup=nginx
    SocketMode=0660
    RuntimeDirectory=vpn-pack
    RuntimeDirectoryMode=0755
    RemoveOnStop=yes

    [Install]
    WantedBy=sockets.target
  '';

  nginxConf = pkgs.writeText "nginx-vpnpack.conf" ''
    location /vpn-pack/api/ {
        include /usr/share/unifi-core/http/cors.conf;
        include /usr/share/unifi-core/http/security.conf;
        include /usr/share/unifi-core/http/auth.conf;
        include /usr/share/unifi-core/http/proxy.conf;

        proxy_set_header X-VpnPack-Token __VPNPACK_NGINX_TOKEN__;

        proxy_pass http://unix:/run/vpn-pack/manager.sock:/api/;
    }

    location /vpn-pack/ {
        include /usr/share/unifi-core/http/cors.conf;
        include /usr/share/unifi-core/http/security.conf;
        include /usr/share/unifi-core/http/auth.conf;
        include /usr/share/unifi-core/http/proxy.conf;

        proxy_set_header X-VpnPack-Token __VPNPACK_NGINX_TOKEN__;

        error_page 401 403 =302 /;

        proxy_pass http://unix:/run/vpn-pack/manager.sock:/;
    }
  '';
in
pkgs.stdenv.mkDerivation {
  pname = "vpn-pack-deploy";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [
    pkgs.gnutar
    pkgs.gzip
    pkgs.patchelf
  ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin $out/dist
    distDir=$out/dist/vpn-pack
    mkdir -p $distDir/bin $distDir/systemd

    # Copy ARM64 binaries
    cp ${tailscaleBin}/bin/tailscale $distDir/bin/
    cp ${tailscaleBin}/bin/tailscaled $distDir/bin/
    cp ${managerBin}/bin/vpn-pack-manager $distDir/bin/

    # Rewrite interpreter to standard Debian / UniFi OS loader path
    chmod -R u+w $distDir/bin
    for b in $distDir/bin/*; do
      if patchelf --print-interpreter "$b" >/dev/null 2>&1; then
        patchelf --set-interpreter /lib/ld-linux-aarch64.so.1 "$b"
      fi
    done

    # Copy systemd units and nginx config
    cp ${tailscaledService} $distDir/systemd/tailscaled.service
    cp ${tailscaledDefaults} $distDir/systemd/tailscaled.defaults
    cp ${managerService} $distDir/systemd/vpn-pack-manager.service
    cp ${managerSocket} $distDir/systemd/vpn-pack-manager.socket
    cp ${nginxConf} $distDir/nginx-vpnpack.conf

    # Copy install & uninstall scripts
    cp ${vpnPackSrc}/install.sh $distDir/install.sh
    cp ${./uninstall.sh} $distDir/uninstall.sh
    chmod +x $distDir/install.sh $distDir/uninstall.sh

    # Write VERSION metadata
    echo "${version}" > $distDir/VERSION
    echo "tailscale_version: ${tailscaleVersion}" >> $distDir/VERSION
    echo "git_commit: ${gitCommit}" >> $distDir/VERSION

    # Copy binaries to top-level bin before removing dist
    cp $distDir/bin/tailscale $out/bin/
    cp $distDir/bin/tailscaled $out/bin/
    cp $distDir/bin/vpn-pack-manager $out/bin/

    # Package tarball
    tar -czf $out/vpn-pack-${version}.tar.gz -C $out/dist vpn-pack
    rm -rf $out/dist

    ln -s $out/vpn-pack-${version}.tar.gz $out/vpn-pack.tar.gz
  '';

  meta = with lib; {
    description = "Tailscale and web management pack for Ubiquiti Cloud Gateways";
    homepage = "https://github.com/eds-ch/vpn-pack";
    license = licenses.bsd3;
    platforms = [ "aarch64-linux" ];
  };
}
