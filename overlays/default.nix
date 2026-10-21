{ inputs, ... }:
final: prev: {
  # Use the real determinate here if you want it available!
  
  catppuccin-bat-theme = prev.stdenv.mkDerivation {
    pname = "catppuccin-bat-theme";
    version = "699f60f";
    src = prev.fetchFromGitHub {
      owner = "catppuccin";
      repo = "bat";
      rev = "699f60fc8ec434574ca7451b444b880430319941";
      sha256 = "sha256-6fWoCH90IGumAmc4buLRWL0N61op+AuMNN9CAR9/OdI=";
    };
    installPhase = ''
      mkdir -p $out/themes
      cp $src/themes/*.tmTheme $out/themes/
    '';
    meta = {
      description = "Catppuccin themes for bat";
      homepage = "https://github.com/catppuccin/bat";
      license = prev.lib.licenses.mit;
      maintainers = [];
    };
  };

  themes = (prev.themes or {}) // {
    # FIX: Changed `prev` to `final` to reference the package defined above
    bat = final.catppuccin-bat-theme;
  };
  
  n-m3u8dl-re =
    let
      objcSource = prev.writeText "m3u8dl-protocol-main.m" ''
        #import <Cocoa/Cocoa.h>

        @interface AppDelegate : NSObject <NSApplicationDelegate>
        @end

        @implementation AppDelegate
        - (void)applicationWillFinishLaunching:(NSNotification *)notification {
            [[NSAppleEventManager sharedAppleEventManager]
                setEventHandler:self
                    andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                  forEventClass:kInternetEventClass
                     andEventID:kAEGetURL];
        }

        - (void)handleGetURLEvent:(NSAppleEventDescriptor *)event
                   withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
            NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
            if (url) {
                NSTask *task = [[NSTask alloc] init];
                task.executableURL = [NSURL fileURLWithPath:@HANDLER_PATH];
                task.arguments = @[ url ];
                [task launchAndReturnError:nil];
            }
            [NSApp terminate:nil];
        }

        - (void)applicationDidFinishLaunching:(NSNotification *)notification {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [NSApp terminate:nil];
            });
        }
        @end

        int main(int argc, const char * argv[]) {
            @autoreleasepool {
                NSApplication *app = [NSApplication sharedApplication];
                [app setActivationPolicy:NSApplicationActivationPolicyProhibited];
                AppDelegate *delegate = [[AppDelegate alloc] init];
                [app setDelegate:delegate];
                [app run];
            }
            return 0;
        }
      '';

      infoPlist = prev.writeText "M3U8DLProtocol-Info.plist" ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleDevelopmentRegion</key>
          <string>en</string>
          <key>CFBundleExecutable</key>
          <string>M3U8DLProtocol</string>
          <key>CFBundleIdentifier</key>
          <string>io.github.leporuid.m3u8dl-protocol</string>
          <key>CFBundleInfoDictionaryVersion</key>
          <string>6.0</string>
          <key>CFBundleName</key>
          <string>M3U8DLProtocol</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
          <key>CFBundleShortVersionString</key>
          <string>1.0</string>
          <key>CFBundleVersion</key>
          <string>1</string>
          <key>LSUIElement</key>
          <true/>
          <key>NSPrincipalClass</key>
          <string>NSApplication</string>
          <key>CFBundleURLTypes</key>
          <array>
            <dict>
              <key>CFBundleURLName</key>
              <string>Cat-Catch M3U8DL Protocol</string>
              <key>CFBundleURLSchemes</key>
              <array>
                <string>m3u8dl</string>
                <string>m3u8dlre</string>
              </array>
            </dict>
          </array>
        </dict>
        </plist>
      '';
    in
    (prev.n-m3u8dl-re.override {
      buildDotnetModule = args: prev.buildDotnetModule (
        finalAttrs: (args finalAttrs) // {
          dotnet-sdk = prev.dotnetCorePackages.sdk_9_0;
          dotnet-runtime = prev.dotnetCorePackages.runtime_9_0;
          
          projectFile = "src/N_m3u8DL-RE/N_m3u8DL-RE.csproj";
          doCheck = false;
        }
      );
    }).overrideAttrs (old: {
      version = "0.0.0-unstable-${inputs.n-m3u8dl-re.shortRev or "dirty"}";

      src = inputs.n-m3u8dl-re;

      nugetDeps = ./n-m3u8dl-re-deps.nix;
      patches = [];

      postPatch = (old.postPatch or "") + ''
        find . -type f \( -name "*.csproj" -o -name "*.props" \) -exec sed -i 's/net10\.0/net9.0/g' {} +
        find . -type f \( -name "*.csproj" -o -name "*.props" \) -exec sed -i 's/<PublishTrimmed>true<\/PublishTrimmed>//g' {} +
        find . -type f \( -name "*.csproj" -o -name "*.props" \) -exec sed -i 's/<PublishAot>true<\/PublishAot>//g' {} +
        find . -type f \( -name "*.csproj" -o -name "*.props" \) -exec sed -i 's/<PublishSingleFile>true<\/PublishSingleFile>//g' {} +
        
        rm -f src/N_m3u8DL-RE.sln
        rm -rf src/N_m3u8DL-RE.Tests
      '';

      postInstall = (old.postInstall or "") + prev.lib.optionalString prev.stdenv.hostPlatform.isDarwin ''
        cat << 'EOF' > "$out/bin/m3u8dl-handler"
#!${prev.python3}/bin/python3
import base64
import json
import os
import re
import shlex
import subprocess
import sys
import tempfile
import time
import urllib.parse

BIN_DIR = os.path.dirname(os.path.abspath(__file__))
N_M3U8DL_RE_BIN = os.path.join(BIN_DIR, "N_m3u8DL-RE")
FFMPEG_BIN = "${prev.ffmpeg}/bin/ffmpeg"
EXTRA_PATH = f"{BIN_DIR}:${prev.lib.makeBinPath [ prev.ffmpeg ]}"


def ensure_registered() -> None:
    bin_dir = os.path.dirname(os.path.abspath(__file__))
    app_path = os.path.join(os.path.dirname(bin_dir), "Applications", "M3U8DLProtocol.app")
    stamp_dir = os.path.expanduser("~/.cache/n-m3u8dl-re")
    stamp_file = os.path.join(stamp_dir, "registered_path")
    lsregister = "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
    if os.path.exists(lsregister) and os.path.exists(app_path):
        current_stamp = ""
        if os.path.exists(stamp_file):
            try:
                with open(stamp_file, "r") as f:
                    current_stamp = f.read().strip()
            except Exception:
                pass
        if current_stamp != app_path:
            os.makedirs(stamp_dir, exist_ok=True)
            res = subprocess.run([lsregister, "-f", app_path], capture_output=True, check=False)
            if res.returncode == 0:
                try:
                    with open(stamp_file, "w") as f:
                        f.write(app_path)
                except Exception:
                    pass


def notify(title: str, message: str) -> None:
    script = f'display notification {json.dumps(message)} with title {json.dumps(title)}'
    subprocess.run(["/usr/bin/osascript", "-e", script], check=False)


def try_b64_decode(val: str) -> str:
    val = val.strip()
    if not val:
        return ""
    padded = val.replace("-", "+").replace("_", "/")
    padded += "=" * ((4 - len(padded) % 4) % 4)
    try:
        raw = base64.b64decode(padded, validate=False)
        text = raw.decode("utf-8")
        if text and all(ord(c) >= 32 or c in "\t\n\r" for c in text):
            return text
    except Exception:
        pass
    return val


def normalize_args(args: list[str]) -> list[str]:
    home = os.path.expanduser("~")
    normalized = []
    has_save_dir = False
    has_ffmpeg = False

    i = 0
    while i < len(args):
        arg = args[i]
        if "%USERPROFILE%" in arg:
            arg = arg.replace("%USERPROFILE%", home).replace("\\", "/")
        if arg in ("--save-dir", "--tmp-dir") and i + 1 < len(args):
            if arg == "--save-dir":
                has_save_dir = True
            nxt = args[i + 1].replace("%USERPROFILE%", home).replace("\\", "/")
            if nxt.startswith("~"):
                nxt = os.path.expanduser(nxt)
            normalized.extend([arg, nxt])
            i += 2
            continue
        if arg == "--ffmpeg-binary-path":
            has_ffmpeg = True
        if arg == "--cat-catch-test":
            i += 1
            continue
        normalized.append(arg)
        i += 1

    if not has_save_dir:
        normalized.extend(["--save-dir", os.path.join(home, "Downloads")])
    if not has_ffmpeg and os.path.exists(FFMPEG_BIN):
        normalized.extend(["--ffmpeg-binary-path", FFMPEG_BIN])
    return normalized


def build_args_from_fields(url: str, title: str, referer: str, cookie: str) -> list[str]:
    built = []
    if url:
        built.append(url)
    if title:
        safe_title = re.sub(r'[\\/:*?"<>|]+', "_", title).strip()
        built.extend(["--save-name", f"{safe_title}_{int(time.time())}"])
    if referer:
        built.extend(["-H", f"Referer: {referer}"])
    if cookie:
        built.extend(["-H", f"Cookie: {cookie}"])
    built.extend(["--auto-select", "--del-after-done", "--no-log"])
    return normalize_args(built)


def parse_url_payload(raw_url: str) -> tuple[list[str], bool]:
    silent = os.environ.get("M3U8DL_SILENT", "0") == "1"
    payload = re.sub(r"^(m3u8dlre|m3u8dl)://?", "", raw_url, flags=re.IGNORECASE)

    if payload.startswith("?") or payload.startswith("download?") or ("=" in payload and "&" in payload and not payload.startswith('"')):
        qs_part = payload.split("?", 1)[-1]
        params = urllib.parse.parse_qs(qs_part, keep_blank_values=False)
        if "silent" in params:
            silent = params["silent"][0] in ("1", "true", "yes")
        if "args" in params:
            decoded = try_b64_decode(urllib.parse.unquote(params["args"][0]))
            return normalize_args(shlex.split(decoded)), silent

        url = try_b64_decode(urllib.parse.unquote(params.get("url", [""])[0]))
        title = try_b64_decode(urllib.parse.unquote(params.get("title", [""])[0]))
        referer = try_b64_decode(urllib.parse.unquote(params.get("referer", [""])[0]))
        cookie = try_b64_decode(urllib.parse.unquote(params.get("cookie", [""])[0]))
        return build_args_from_fields(url, title, referer, cookie), silent

    unquoted = urllib.parse.unquote(payload.strip("/"))
    decoded = try_b64_decode(unquoted)
    if not any(tok in decoded for tok in ("http", "--", "-H", "-sv", "-sa", "/")):
        decoded = unquoted

    return normalize_args(shlex.split(decoded)), silent


def get_btt_variable(name: str) -> str:
    script = f'tell application "BetterTouchTool" to get_string_variable {json.dumps(name)}'
    res = subprocess.run(["/usr/bin/osascript", "-e", script], capture_output=True, text=True, check=False)
    val = res.stdout.strip()
    return "" if val == "missing value" else val


def clear_btt_variables(names: list[str]) -> None:
    lines = ['tell application "BetterTouchTool"']
    for name in names:
        lines.append(f'  set_string_variable {json.dumps(name)} to ""')
    lines.append("end tell")
    subprocess.run(["/usr/bin/osascript", "-e", "\n".join(lines)], capture_output=True, check=False)


def parse_from_btt() -> tuple[list[str], bool]:
    var_names = [
        "cat_args", "args",
        "cat_url", "url",
        "cat_title", "title",
        "cat_referer", "referer",
        "cat_cookie", "cookie",
        "cat_silent", "silent",
    ]
    vals = {k: get_btt_variable(k) for k in var_names}
    clear_btt_variables(var_names)

    silent_val = vals["cat_silent"] or vals["silent"] or os.environ.get("M3U8DL_SILENT", "0")
    silent = silent_val in ("1", "true", "yes")

    raw_args = vals["cat_args"] or vals["args"]
    if raw_args:
        decoded = try_b64_decode(urllib.parse.unquote(raw_args))
        return normalize_args(shlex.split(decoded)), silent

    url = try_b64_decode(urllib.parse.unquote(vals["cat_url"] or vals["url"]))
    title = try_b64_decode(urllib.parse.unquote(vals["cat_title"] or vals["title"]))
    referer = try_b64_decode(urllib.parse.unquote(vals["cat_referer"] or vals["referer"]))
    cookie = try_b64_decode(urllib.parse.unquote(vals["cat_cookie"] or vals["cookie"]))

    return build_args_from_fields(url, title, referer, cookie), silent


def install_btt_trigger() -> None:
    trigger_obj = {
        "BTTTriggerType": 643,
        "BTTTriggerTypeDescription": "Named Trigger: cat-catch-dl",
        "BTTTriggerClass": "BTTTriggerTypeOtherTriggers",
        "BTTTriggerName": "cat-catch-dl",
        "BTTEnabled": 1,
        "BTTActionsToExecute": [
            {
                "BTTPredefinedActionType": 206,
                "BTTPredefinedActionName": "Execute Shell Script  or  Task",
                "BTTShellTaskActionScript": 'export PATH="/etc/profiles/per-user/$USER/bin:$HOME/.nix-profile/bin:/run/current-system/sw/bin:$PATH"\nm3u8dl-handler --from-btt',
                "BTTShellTaskActionConfig": "/bin/sh:::-c:::-:::",
            }
        ],
    }
    encoded = urllib.parse.quote(json.dumps(trigger_obj, separators=(",", ":")))
    subprocess.run(["/usr/bin/open", f"btt://add_new_trigger/?json={encoded}"], check=False)
    print("Sent cat-catch-dl Named Trigger registration to BetterTouchTool.")


def launch_download(cli_args: list[str], silent: bool) -> None:
    ensure_registered()

    if not cli_args:
        notify("N_m3u8DL-RE", "No valid download parameters received")
        return

    cmd = [N_M3U8DL_RE_BIN] + cli_args
    quoted_cmd = " ".join(shlex.quote(x) for x in cmd)
    env = os.environ.copy()
    env["PATH"] = f"{EXTRA_PATH}:{env.get('PATH', '/usr/bin:/bin')}"

    if silent:
        if "--auto-select" not in cli_args:
            cmd.append("--auto-select")
        notify("N_m3u8DL-RE", "Starting background stream download...")
        res = subprocess.run(cmd, env=env, check=False)
        if res.returncode == 0:
            notify("N_m3u8DL-RE", "✅ Download complete!")
        else:
            notify("N_m3u8DL-RE", f"❌ Download failed (Exit code: {res.returncode})")
        return

    fd, runner_path = tempfile.mkstemp(prefix="n-m3u8dl-re-", suffix=".sh")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        f.write("#!/bin/bash\n")
        f.write(f"export PATH={shlex.quote(EXTRA_PATH)}:\"$PATH\"\n")
        f.write("echo '🚀 N_m3u8DL-RE starting download...'\n")
        f.write(f"echo {shlex.quote(quoted_cmd)}\n")
        f.write("echo ''\n")
        f.write(f"{quoted_cmd}\n")
        f.write("status=$?\n")
        f.write("if [ $status -eq 0 ]; then\n")
        f.write("  /usr/bin/osascript -e 'display notification \"✅ Download complete!\" with title \"N_m3u8DL-RE\"'\n")
        f.write("  sleep 1\n")
        f.write("else\n")
        f.write("  /usr/bin/osascript -e 'display notification \"❌ Download error occurred. Check terminal output.\" with title \"N_m3u8DL-RE\"'\n")
        f.write("  echo ''\n")
        f.write("  read -n 1 -s -r -p 'Press any key to close...'\n")
        f.write("fi\n")
        f.write(f"rm -f {shlex.quote(runner_path)}\n")
    os.chmod(runner_path, 0o755)

    ghostty_app = "/Applications/Ghostty.app"
    if os.path.exists(ghostty_app):
        subprocess.Popen(["/usr/bin/open", "-na", ghostty_app, "--args", "-e", "/bin/bash", runner_path])
    else:
        apple_script = f'tell application "Terminal" to do script {json.dumps(runner_path)} & activate'
        subprocess.Popen(["/usr/bin/osascript", "-e", apple_script])


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: m3u8dl-handler <m3u8dl://... | --from-btt | --install-btt-trigger | --register>")
        sys.exit(1)

    arg1 = sys.argv[1]
    if arg1 in ("--register", "--register-protocol"):
        ensure_registered()
        print("Registered M3U8DLProtocol.app with macOS LaunchServices.")
        return
    elif arg1 == "--install-btt-trigger":
        install_btt_trigger()
        return
    elif arg1 == "--from-btt":
        cli_args, silent = parse_from_btt()
    else:
        cli_args, silent = parse_url_payload(arg1)

    launch_download(cli_args, silent)


if __name__ == "__main__":
    main()
EOF
        chmod +x "$out/bin/m3u8dl-handler"

        appDir="$out/Applications/M3U8DLProtocol.app/Contents"
        mkdir -p "$appDir/MacOS"
        cp "${infoPlist}" "$appDir/Info.plist"

        $CC -O2 -Wall -Wno-unused-parameter "${objcSource}" \
          -framework Cocoa \
          -DHANDLER_PATH="\"$out/bin/m3u8dl-handler\"" \
          -o "$appDir/MacOS/M3U8DLProtocol"
      '';

      postFixup = (old.postFixup or "") + prev.lib.optionalString prev.stdenv.hostPlatform.isDarwin ''
        tmpWrapper=$(mktemp)
        cat << 'WRAPPER_HEADER' > "$tmpWrapper"
STAMP="$HOME/.cache/n-m3u8dl-re/registered_path"
APP="@APP_PATH@"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if [ -f "$LSREGISTER" ] && [ -d "$APP" ]; then
  if [ ! -f "$STAMP" ] || [ "$(cat "$STAMP" 2>/dev/null)" != "$APP" ]; then
    mkdir -p "$(dirname "$STAMP")" 2>/dev/null
    ("$LSREGISTER" -f "$APP" >/dev/null 2>&1 && echo "$APP" > "$STAMP" 2>/dev/null) &
  fi
fi
WRAPPER_HEADER
        substituteInPlace "$tmpWrapper" --replace-fail "@APP_PATH@" "$out/Applications/M3U8DLProtocol.app"

        mv "$out/bin/N_m3u8DL-RE" "$out/bin/.N_m3u8DL-RE-bin"
        head -n 1 "$out/bin/.N_m3u8DL-RE-bin" > "$out/bin/N_m3u8DL-RE"
        cat "$tmpWrapper" >> "$out/bin/N_m3u8DL-RE"
        tail -n +2 "$out/bin/.N_m3u8DL-RE-bin" >> "$out/bin/N_m3u8DL-RE"
        rm -f "$tmpWrapper" "$out/bin/.N_m3u8DL-RE-bin"
        chmod +x "$out/bin/N_m3u8DL-RE"
      '';
    });

  megabasterd = prev.megabasterd.overrideAttrs (old: rec {
    version = "8.61"; 
    src = final.fetchFromGitHub {
      owner = "tonikelope";
      repo = "megabasterd";
      tag = "v${version}";
      hash = "sha256-H3nW+phtT30nhKIBxlS3CAqVxFIWcBvStbNlnobWEiQ="; 
    };
    installPhase = ''
      runHook preInstall

      makeWrapper ${final.jre}/bin/java $out/bin/megabasterd \
        --add-flags "-jar $out/share/java/MegaBasterd-${version}-jar-with-dependencies.jar"

      install -Dm644 target/MegaBasterd-${version}-jar-with-dependencies.jar $out/share/java/MegaBasterd-${version}-jar-with-dependencies.jar

      runHook postInstall
    '';
  });
  atuin = prev.atuin.overrideAttrs (old: {
    doCheck = false;
    doInstallCheck = false;
  });
}
