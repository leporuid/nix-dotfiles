# Oracle Cloud Infrastructure (OCI) Ampere A1 base configuration and qcow2 image builder.
{ inputs, flake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/oci-image.nix"
  ];

  oci.efi = true;

  # Override OCIImage derivation so it builds directly from our flake host configuration
  # instead of expecting a standalone /etc/nixos/configuration.nix from oci-config-user.nix.
  # Also tolerate unprivileged TMPDIR chmod failure inside sandboxed Linux builder.
  system.build.OCIImage = lib.mkForce (
    let
      rawImage = import "${inputs.nixpkgs}/nixos/lib/make-disk-image.nix" {
        inherit config lib pkgs;
        diskSize = config.virtualisation.diskSize or (8 * 1024);
        name = "oci-image";
        baseName = config.image.baseName or "nixos-image-oci";
        configFile = "${flake}/hosts/nixos/configuration.nix";
        format = "qcow2";
        copyChannel = false;
        partitionTableType = if config.oci.efi then "efi" else "legacy";
      };
    in
    lib.overrideDerivation rawImage (old: {
      preVM = builtins.replaceStrings [ "chmod 755 \"$TMPDIR\"" ] [ "chmod 755 \"$TMPDIR\" 2>/dev/null || true" ] old.preVM;
    })
  );

  # Workaround for macOS APFS case-hack collision in ncurses terminfo when creating initrd.
  # On case-insensitive filesystems, share/terminfo/l collides with L and gets renamed to l~nix~case~hack~1.
  boot.initrd.systemd.contents."/etc/terminfo/l/linux".source = lib.mkForce (
    pkgs.runCommand "initrd-terminfo-linux" { } ''
      if [ -f "${pkgs.ncurses}/share/terminfo/l/linux" ]; then
        cp "${pkgs.ncurses}/share/terminfo/l/linux" "$out"
      else
        cp ${pkgs.ncurses}/share/terminfo/l*case*hack*/linux "$out"
      fi
    ''
  );

  # Oracle guideline G06: use the OCI metadata service NTP with public fallback.
  services.timesyncd = {
    enable = true;
    servers = [ "169.254.169.254" ];
    fallbackServers = [ "pool.ntp.org" ];
  };

  # systemd-networkd config: OCI paravirtualized NIC (typically ens3) via DHCP + IPv6 RA.
  systemd.network.networks."10-eth" = {
    matchConfig = {
      Name = "ens*";
      Type = "ether";
    };
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = true;
    };
  };
}
