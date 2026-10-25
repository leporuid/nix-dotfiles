{ ... }:
{ pkgs, ... }:
let
  tailzeroPkg = pkgs.callPackage ../../packages/tailzero.nix { };
in
{
  environment.systemPackages = [
    tailzeroPkg
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/tailzero 0750 root root -"
    "d /etc/border0 0750 root root -"
  ];

  systemd.services.tailzero-bootstrap = {
    description = "Bootstrap Tailzero connector registration";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "agenix.service"
    ];
    wants = [
      "network-online.target"
      "agenix.service"
    ];
    before = [ "tailzero.service" ];
    path = with pkgs; [
      bashInteractive
      coreutils
      nettools
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "120";
    };
    script = ''
      set -euo pipefail
      SECRET=/run/agenix/tailzero-invite
      [ -s "$SECRET" ] || { echo "Missing or empty secret: $SECRET" >&2; exit 1; }
      INVITE="$(tr -d '\r\n' < "$SECRET")"
      [ -n "$INVITE" ] || { echo "Invite empty after trimming" >&2; exit 1; }

      CONNECTOR_NAME="$(hostname | tr . -)"

      set +e

      OUT="$(${tailzeroPkg}/bin/tailzero install \
        --connector-name "$CONNECTOR_NAME" \
        --border0-invite-code "$INVITE" \
        --service-user root 2>&1)"
      RC=$?
      set -e

      if [ $RC -eq 0 ]; then
        echo "$OUT"
        exit 0
      fi
      echo "$OUT"
      echo "$OUT" | grep -qi "already installed" && exit 0
      exit $RC
    '';
  };

  age.secrets.tailzero-token = {
    file = ../../hosts/nixos/tailzero-token.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  systemd.services.tailzero = {
    description = "Border0 Tailzero Connector";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "tailzero-bootstrap.service"
      "agenix.service"
    ];
    wants = [
      "network-online.target"
      "tailzero-bootstrap.service"
      "agenix.service"
    ];
    path = with pkgs; [
      bashInteractive
      coreutils
    ];
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "10s";
      TimeoutStartSec = "60";
      ExecStart = "${pkgs.bashInteractive}/bin/bash -lc 'set -euo pipefail; TOKEN=\"$(tr -d \"\\r\\n\" < /run/agenix/tailzero-token)\"; exec ${tailzeroPkg}/bin/tailzero start --border0-token \"$TOKEN\"'";
    };
  };
}
