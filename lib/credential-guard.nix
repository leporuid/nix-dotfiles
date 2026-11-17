# Cross-platform fail-fast SSH/Git credential guard for AI coding agents.
# Prevents agent-spawned commands from blocking on hidden passphrase or host-key prompts.
{ pkgs }:
let
  inherit (pkgs.lib.attrsets) mapAttrsToList;
  inherit (pkgs.lib.meta) getExe;
  inherit (pkgs.lib.strings) concatStringsSep escapeShellArg;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  notifyRefusal =
    title: body:
    if isDarwin then
      ''/usr/bin/osascript -e 'display notification "${body}" with title "${title}"' >/dev/null 2>&1 || true''
    else
      ''
        if command -v notify-send >/dev/null 2>&1; then
          notify-send -u critical "${title}" "${body}" >/dev/null 2>&1 || true
        fi
      '';

  askpass = pkgs.writeShellApplication {
    name = "agent-askpass-guard";
    text = ''
      prompt="''${1:-<none>}"
      ${notifyRefusal "Credential Guard" "An AI agent hit an interactive SSH/Git prompt."}
      case "$prompt" in
        *"(yes/no"* | *fingerprint*)
          {
            echo "=============================================================="
            echo "AGENT NOTICE: confirming an unknown SSH host key is blocked"
            echo "inside AI coding agents. Do NOT retry this command."
            echo "Prompt was: $prompt"
            echo "Ask the user to verify and accept the host key themselves"
            echo "(or to run this command), then continue."
            echo "=============================================================="
          } >&2
          ;;
        *)
          {
            echo "=============================================================="
            echo "AGENT NOTICE: interactive passphrase/credential entry is blocked"
            echo "inside AI coding agents. Do NOT retry this command."
            echo "Prompt was: $prompt"
            echo "Ask the user to run this command, or to unlock the credential"
            echo "(e.g. 'ssh-add', 'age-plugin-se', or a manual push/sign), themselves."
            echo "=============================================================="
          } >&2
          ;;
      esac
      exit 1
    '';
  };

  agentEnv = {
    GIT_ASKPASS = getExe askpass;
    SSH_ASKPASS = getExe askpass;
    SSH_ASKPASS_REQUIRE = "force";
  };

  wrapPackage =
    pkg:
    pkgs.symlinkJoin {
      name = "${pkg.pname or pkg.name}-guarded";
      paths = [ pkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        for bin in "$out"/bin/*; do
          [ -e "$bin" ] || continue
          wrapProgram "$bin" \
            ${concatStringsSep " \\\n            " (
              mapAttrsToList (name: value: "--set ${name} ${escapeShellArg value}") agentEnv
            )}
        done
      '';
    };
in
{
  inherit
    agentEnv
    askpass
    wrapPackage
    ;
}
