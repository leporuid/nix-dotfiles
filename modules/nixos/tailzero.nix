{ pkgs, ... }:
let
  track = "stable";
  base = "https://tailscale.border0.com/tailzero/${track}";
in
{
  systemd.tmpfiles.rules = [
    "d $out/bin 0755 root root -"
    "d $out/lib/tailzero 0750 root root -"
    "d /etc/border0 0750 root root -"
  ];
  systemd.services.tailzero-install = {
    description = "Install tailzero binary";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [ bash coreutils curl gawk gnugrep ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "120";
    };
    script = ''
      set -euo pipefail
      TMP="$(mktemp -d)"
      trap 'rm -rf "$out"' EXIT
      ARCH="$(uname -m)"
      case "$ARCH" in
        x86_64) A="amd64" ;;
        aarch64|arm64) A="arm64" ;;
        armv7l) A="arm" ;;
        *) echo "Unsupported arch: $ARCH"; exit 1 ;;
      esac
      VER="$(curl -fsSL '${base}/latest_version.txt' | tr -d '[:space:]')"
      FILE="tailzero_''${VER}_linux_''${A}"
      curl -fsSL "${base}/''${FILE}" -o "$out/tailzero"
      curl -fsSL "${base}/''${FILE}.sha256" -o "$out/tailzero.sha256"
      EXP="$(awk '{print $1}' "$out/tailzero.sha256")"
      ACT="$(sha256sum "$out/tailzero" | awk '{print $1}')"
      [ "$EXP" = "$ACT" ]
      install -m 0755 "$out/tailzero" $out/bin/tailzero
    '';
  };
  systemd.services.tailzero-bootstrap = {
    description = "Bootstrap Tailzero connector registration";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "tailzero-install.service" "agenix.service" ];
    wants = [ "network-online.target" "tailzero-install.service" "agenix.service" ];
    before = [ "tailzero.service" ];
    path = with pkgs; [ bash coreutils ];
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
      CONNECTOR_NAME="$(${pkgs.hostname}/bin/hostname | tr . -)"
      set +e
      OUT="$($out/bin/tailzero install \
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
    file = ../../secrets/tailzero-token.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };
  systemd.services.tailzero = {
    description = "Border0 Tailzero Connector";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "tailzero-install.service" "agenix.service" ];
    wants = [ "network-online.target" "tailzero-install.service" "agenix.service" ];
    path = with pkgs; [ bash coreutils ];
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "10s";
      TimeoutStartSec = "60";
      ExecStart = "${pkgs.bash}/bin/bash -lc 'set -euo pipefail; TOKEN=\"$(tr -d \"\\r\\n\" < /run/agenix/tailzero-token)\"; exec $out/bin/tailzero start --border0-token \"$TOKEN\"'";
    };
  };
}