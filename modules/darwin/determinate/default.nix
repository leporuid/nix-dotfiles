{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.determinateNix;
  t = lib.types;
  json = pkgs.formats.json { };
  inherit (pkgs.stdenv.hostPlatform) system;

  # Validate known Nixd settings without filling absent keys or stripping explicit nulls
  fields =
    schema: value:
    builtins.isAttrs value
    && lib.all (name: !(builtins.hasAttr name value) || schema.${name} value.${name}) (
      builtins.attrNames schema
    );
  strings = value: builtins.isList value && lib.all builtins.isString value;
  positive = value: builtins.isInt value && value > 0;
  runtimePath =
    value:
    builtins.isString value
    && lib.hasPrefix "/" value
    && value != "/nix/store"
    && !lib.hasPrefix "/nix/store/" value
    && !builtins.hasContext value;

  nixdType = t.addCheck (t.attrsOf json.type) (fields {
    builder = fields {
      state =
        value:
        builtins.elem value [
          "enabled"
          "disabled"
        ];
      cpuCount = positive;
      memoryBytes = positive;
    };
    garbageCollector = fields {
      strategy =
        value:
        builtins.elem value [
          "automatic"
          "disabled"
        ];
    };
    authentication = fields {
      additionalNetrcSources = value: builtins.isList value && lib.all runtimePath value;
    };
    edgeCacheSubstituters = strings;
  });

  singleLine = t.addCheck t.str (value: builtins.match "[^\r\n]*" value != null);
  atom = t.oneOf [
    t.bool
    t.int
    t.float
    singleLine
    t.path
    t.package
  ];

  valueString =
    value:
    if builtins.isBool value then
      lib.boolToString value
    else if builtins.isFloat value then
      lib.strings.floatToString value
    else if builtins.isList value then
      lib.concatMapStringsSep " " valueString value
    else
      toString value;

  settings = lib.filterAttrs (_: value: value != null) cfg.customSettings;

  # Nix requires extra-* options after their base option
  renderSettings =
    extra:
    lib.generators.toKeyValue { mkKeyValue = name: value: "${name} = ${value}"; } (
      lib.mapAttrs (_: valueString) (
        lib.filterAttrs (name: _: lib.hasPrefix "extra-" name == extra) settings
      )
    );

  daemonConfig = json.generate "determinate-config.json" cfg.determinateNixd;
  customConfig = pkgs.writeTextFile {
    name = "nix.custom.conf";
    text = renderSettings false + renderSettings true;
    checkPhase = ''
      ln -s "$out" nix.conf
      if ! diagnostics=$(HOME="$TMPDIR" NIX_STATE_DIR="$TMPDIR/state" \
        NIX_CONF_DIR="$PWD" NIX_USER_CONF_FILES=/dev/null NIX_CONFIG="" \
        ${lib.getExe cfg.package} --extra-experimental-features nix-command \
        config show --json 2>&1 >/dev/null); then
        printf >&2 '%s\n' "$diagnostics"
        exit 1
      fi
      if [[ -n $diagnostics ]]; then
        printf >&2 '%s\n' "$diagnostics"
        exit 1
      fi
    '';
  };

  nixBin = "${cfg.package}/bin";
  # Copy determinate-nixd outside /nix/store so the early-boot init job can mount the APFS store volume
  bootstrapPath = builtins.unsafeDiscardStringContext "/usr/local/libexec/darwin/${baseNameOf cfg.daemon.package}/determinate-nixd";
  # Default determinate-nixd config path; a real file so both boot-time init and the daemon can read it before /nix mounts
  configPath = "/etc/determinate/config.json";
  initArguments = [
    bootstrapPath
    "--nix-bin"
    (builtins.unsafeDiscardStringContext nixBin)
    "init"
  ];
  limits = {
    NumberOfFiles = 1048576;
    NumberOfProcesses = 1048576;
    Stack = 67108864;
  };
  reserved = [
    "bash-prompt-prefix"
    "external-builders"
    "nix-path"
    "netrc-file"
    "ssl-cert-file"
    "upgrade-nix-store-path-url"
  ];

  command = lib.escapeShellArgs;
  failIf = condition: message: ''
    if ${condition}; then
      printf >&2 'determinateNix: %s\n' ${lib.escapeShellArg message}
      exit 1
    fi
  '';

  daemonLabel = "systems.determinate.nix-daemon";
  storeLabel = "systems.determinate.nix-store";
  hookLabel = "systems.determinate.nix-installer.nix-hook";

  daemonPlist = pkgs.writeText "${daemonLabel}.plist" (
    lib.generators.toPlist { escape = true; } {
      Label = daemonLabel;
      # Use the off-store copy so launchd can exec it at boot before /nix is mounted;
      # config is read from the default configPath, which is also outside /nix.
      ProgramArguments = [
        bootstrapPath
        "--nix-bin"
        (builtins.unsafeDiscardStringContext nixBin)
        "daemon"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/var/log/determinate-nix-daemon.log";
      StandardOutPath = "/var/log/determinate-nix-daemon.log";
      SoftResourceLimits = limits;
      HardResourceLimits = limits;
      Sockets =
        lib.mapAttrs
          (_: path: {
            SockFamily = "Unix";
            SockPassive = true;
            SockPathName = path;
          })
          {
            "nix-daemon.socket" = "/var/run/nix-daemon.socket";
            "determinate-nixd.socket" = "/var/run/determinate-nixd.socket";
          };
    }
  );

  storePlist = pkgs.writeText "${storeLabel}.plist" (
    lib.generators.toPlist { escape = true; } {
      Label = storeLabel;
      ProgramArguments = initArguments;
      RunAtLoad = true;
      StandardErrorPath = "/var/log/determinate-nix-init.log";
      StandardOutPath = "/var/log/determinate-nix-init.log";
    }
  );

  hookPlist = pkgs.writeText "${hookLabel}.plist" (
    lib.generators.toPlist { escape = true; } {
      Label = hookLabel;
      ProgramArguments = [ "/usr/bin/true" ];
      RunAtLoad = true;
    }
  );

  stateDir = "/var/db/determinate-nix";
  managedMarker = "${stateDir}/managed";
  customConfStamp = "${stateDir}/custom-conf";

  launchdHelpers = ''
    launchd_bootout() {
      local target="$1"
      if ! /bin/launchctl bootout --wait "$target" 2>/dev/null; then
        if /bin/launchctl print "$target" >/dev/null 2>&1; then
          return 1
        fi
      fi
    }

    install_plist() {
      local src="$1" dst="$2"
      if [ -L "$dst" ]; then
        rm -f -- "$dst"
      fi
      install --mode=644 --owner=0 --group=0 -- "$src" "$dst"
    }
  '';

  mkCheckDaemonScript =
    name: binDir:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [
        pkgs.coreutils
        pkgs.jq
      ];
      text = ''
        expected_version="$(NIX_CONF_DIR=/var/empty NIX_USER_CONF_FILES=/dev/null NIX_CONFIG="" ${
          command [
            "${binDir}/nix-daemon"
            "--version"
          ]
        })"
        expected_ver="''${expected_version##* }"

        store_info=""
        for _ in $(seq 1 10); do
          if store_info="$(timeout --foreground --kill-after=5 30 ${
            command [
              "${binDir}/nix"
              "--extra-experimental-features"
              "nix-command"
              "store"
              "info"
              "--json"
              "--store"
              "daemon"
            ]
          } 2>/dev/null)"; then
            break
          fi
          sleep 0.5
        done

        ${failIf "[[ -z $store_info ]]" "failed to query running Nix daemon"}
        if ! jq --exit-status --arg version "$expected_ver" '.version == $version' <<< "$store_info" >/dev/null; then
          printf >&2 'determinateNix: the running Nix daemon does not match the selected runtime (%s)\n' "$expected_ver"
          exit 1
        fi
      '';
    };

  verifyEnabledScript = pkgs.writeShellApplication {
    name = "determinate-verify-enabled";
    runtimeInputs = [
      cfg.package
      pkgs.cctools
      pkgs.coreutils
    ];
    text = ''
      ${failIf "[[ ! -d /nix/var/nix/db || ! -f /etc/fstab ]]" "Determinate Nix must be installed before enabling determinateNix"}
      ${failIf "! /usr/bin/grep -Eq '^[^#]+[[:space:]]/nix[[:space:]]+apfs[[:space:]]' /etc/fstab" "determinateNix requires an existing APFS Nix volume"}
      ${failIf "! /usr/bin/dscl /Local/Default -read /Groups/nixbld >/dev/null 2>&1" "determinateNix requires the installer's nixbld group"}
      ${failIf "[[ -e /Library/LaunchDaemons/org.nixos.nix-daemon.plist ]]" "remove the upstream Nix daemon before enabling Determinate runtime management"}
      ${failIf "/bin/launchctl print system/org.nixos.nix-daemon >/dev/null 2>&1" "unload the upstream Nix daemon before enabling Determinate runtime management"}
      ${failIf "[[ ! -L /nix/var/nix/daemon-socket/socket || $(readlink --canonicalize-missing -- /nix/var/nix/daemon-socket/socket) != $(readlink --canonicalize-missing -- /var/run/nix-daemon.socket) ]]" "the Nix daemon socket must point to /var/run/nix-daemon.socket"}

      determinate_version="$(NIX_CONF_DIR=/var/empty NIX_USER_CONF_FILES=/dev/null NIX_CONFIG="" ${
        command [
          "${cfg.package}/bin/nix"
          "--version"
        ]
      })"
      ${failIf "[[ $determinate_version != *'(Determinate Nix '* ]]" "determinateNix.package must provide Determinate Nix"}
      ${lib.concatMapStringsSep "\n"
        (
          name:
          failIf "[[ ! -x ${command [ "${cfg.package}/bin/${name}" ]} ]]" "determinateNix.package must provide ${name}"
        )
        [
          "nix-env"
          "nix-daemon"
          "nix-store"
        ]
      }

      /usr/bin/codesign --verify --strict ${command [ "${cfg.daemon.package}/bin/determinate-nixd" ]}
      determinate_libraries="$(${lib.getExe' pkgs.cctools "otool"} -L ${
        command [ "${cfg.daemon.package}/bin/determinate-nixd" ]
      })"
      ${failIf ''/usr/bin/tail -n +2 <<< "$determinate_libraries" | /usr/bin/grep -Ev "^[[:space:]]+(/usr/lib/|/System/Library/)" >/dev/null'' "Nixd must use only macOS libraries for early boot"}

      ${lib.concatMapStringsSep "\n"
        (path: ''
          if [[ -e ${command [ path ]} || -L ${command [ path ]} ]]; then
            ${failIf "[[ -L ${command [ path ]} || ! -d ${command [ path ]} ]]" "Nixd bootstrap parent must be a real directory: ${path}"}
            determinate_owner=$(stat --format=%u -- ${command [ path ]})
            determinate_mode=$(stat --format=%a -- ${command [ path ]})
            ${failIf "[[ $determinate_owner != 0 ]] || (( 8#$determinate_mode & 0022 ))" "Nixd bootstrap parent must be root-owned and writable only by root: ${path}"}
          fi
        '')
        [
          "/usr/local"
          "/usr/local/libexec"
          "/usr/local/libexec/darwin"
          (dirOf bootstrapPath)
        ]
      }
      if [[ -e ${command [ bootstrapPath ]} || -L ${command [ bootstrapPath ]} ]]; then
        ${failIf "[[ -L ${command [ bootstrapPath ]} || ! -f ${command [ bootstrapPath ]} || ! -x ${command [ bootstrapPath ]} ]]" "Nixd bootstrap executable must be a regular executable"}
        determinate_owner=$(stat --format=%u -- ${command [ bootstrapPath ]})
        determinate_mode=$(stat --format=%a -- ${command [ bootstrapPath ]})
        ${failIf "[[ $determinate_owner != 0 ]] || (( 8#$determinate_mode & 0022 ))" "Nixd bootstrap executable must be root-owned and writable only by root"}
      fi

      ${lib.concatMapStringsSep "\n"
        (entry: ''
          if [[ -e ${command [ entry.path ]} ]]; then
            ${failIf "! /usr/bin/plutil -lint ${command [ entry.path ]} >/dev/null 2>&1" "existing launchd plist is invalid: ${entry.path}"}
            plist_label=$(/usr/bin/plutil -extract Label raw -o - -- ${command [ entry.path ]} 2>/dev/null || true)
            if [[ $plist_label != ${command [ entry.label ]} ]]; then
              printf >&2 'determinateNix: refusing to overwrite unexpected plist %s (found label: %s)\n' ${command [ entry.path ]} "$plist_label"
              exit 1
            fi
          fi
        '')
        [
          {
            label = daemonLabel;
            path = "/Library/LaunchDaemons/${daemonLabel}.plist";
          }
          {
            label = storeLabel;
            path = "/Library/LaunchDaemons/${storeLabel}.plist";
          }
          {
            label = hookLabel;
            path = "/Library/LaunchDaemons/${hookLabel}.plist";
          }
        ]
      }
    ''
    + lib.concatMapStringsSep "\n" (path: ''
      ${failIf "[[ ! -f ${command [ path ]} ]]" "Nixd authentication source must exist: ${path}"}
      determinate_netrc=$(readlink --canonicalize -- ${command [ path ]})
      ${failIf "[[ $determinate_netrc == /nix/store/* ]]" "Nixd authentication source must resolve outside the Nix store: ${path}"}
    '') (cfg.determinateNixd.authentication.additionalNetrcSources or [ ]);
  };

  checkEnabledDaemon = mkCheckDaemonScript "determinate-check-daemon" nixBin;

  activateEnabledScript = pkgs.writeShellApplication {
    name = "determinate-activate";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      ${launchdHelpers}

      # Stop installer repair before modifying the Determinate plists
      if /bin/launchctl print system/${hookLabel} >/dev/null 2>&1; then
        launchd_bootout system/${hookLabel}
      fi

      # Copy determinate-nixd outside /nix/store for early boot before /nix mounts
      install --directory --mode=755 --owner=0 --group=0 -- ${command [ (dirOf bootstrapPath) ]}
      if ! cmp --silent -- ${
        command [
          "${cfg.daemon.package}/bin/determinate-nixd"
          bootstrapPath
        ]
      } 2>/dev/null; then
        determinate_copy="$(${
          command [
            "mktemp"
            "--tmpdir=${dirOf bootstrapPath}"
            ".nixd.XXXXXXXX"
          ]
        })"
        trap 'rm --force -- "$determinate_copy"' EXIT
        install --mode=755 --owner=0 --group=0 --no-target-directory -- \
          ${command [ "${cfg.daemon.package}/bin/determinate-nixd" ]} "$determinate_copy"
        /usr/bin/codesign --verify --strict "$determinate_copy"
        mv --force --no-target-directory -- "$determinate_copy" ${command [ bootstrapPath ]}
        trap - EXIT
      fi

      # Install the Nixd config as a real file so boot-time init honors it (builder, telemetry, ...)
      install --directory --mode=755 --owner=0 --group=0 -- ${command [ (dirOf configPath) ]}
      if ! cmp --silent -- ${
        command [
          daemonConfig
          configPath
        ]
      } 2>/dev/null; then
        install --mode=644 --owner=0 --group=0 --no-target-directory -- ${
          command [
            daemonConfig
            configPath
          ]
        }
      fi

      # Regenerate /etc/nix/nix.conf for the pinned runtime before restarting nix-daemon
      ${command (
        initArguments
        ++ [
          "--stop-after"
          "nix-configuration"
        ]
      )}

      # Defer systems.determinate.nix-store to boot instead of running init during activation
      if ! cmp --silent -- ${command [ storePlist ]} "/Library/LaunchDaemons/${storeLabel}.plist" 2>/dev/null; then
        install_plist ${command [ storePlist ]} "/Library/LaunchDaemons/${storeLabel}.plist"
      fi

      if ! cmp --silent -- ${command [ hookPlist ]} "/Library/LaunchDaemons/${hookLabel}.plist" 2>/dev/null \
        || ! /bin/launchctl print system/${hookLabel} >/dev/null 2>&1; then
        if /bin/launchctl print system/${hookLabel} >/dev/null 2>&1; then
          launchd_bootout system/${hookLabel}
        fi
        install_plist ${command [ hookPlist ]} "/Library/LaunchDaemons/${hookLabel}.plist"
        /bin/launchctl enable system/${hookLabel}
        /bin/launchctl bootstrap system "/Library/LaunchDaemons/${hookLabel}.plist"
      fi

      install --directory --mode=755 --owner=0 --group=0 -- ${command [ stateDir ]}
      previous_custom_conf=""
      if [ -f ${command [ customConfStamp ]} ]; then
        previous_custom_conf="$(cat ${command [ customConfStamp ]})"
      fi

      if ! cmp --silent -- ${command [ daemonPlist ]} "/Library/LaunchDaemons/${daemonLabel}.plist" 2>/dev/null \
        || [ "$previous_custom_conf" != ${command [ (toString customConfig) ]} ] \
        || ! /bin/launchctl print system/${daemonLabel} >/dev/null 2>&1; then
        if /bin/launchctl print system/${daemonLabel} >/dev/null 2>&1; then
          launchd_bootout system/${daemonLabel}
        fi
        install_plist ${command [ daemonPlist ]} "/Library/LaunchDaemons/${daemonLabel}.plist"
        /bin/launchctl enable system/${daemonLabel}
        /bin/launchctl bootstrap system "/Library/LaunchDaemons/${daemonLabel}.plist"
        printf '%s\n' ${command [ (toString customConfig) ]} > ${command [ customConfStamp ]}
      fi

      touch ${command [ managedMarker ]}
      ${lib.getExe checkEnabledDaemon}

      # Prune older bootstrap directories, keeping the active copy and at most one previous backup
      current_dir=${command [ (dirOf bootstrapPath) ]}
      stale_dirs=()
      while IFS= read -r d; do
        if [ -n "$d" ] && [ -d "$d" ] && [ "$d" != "$current_dir" ]; then
          stale_dirs+=("$d")
        fi
      done < <(ls -dt /usr/local/libexec/darwin/*-determinate-nixd-* 2>/dev/null || true)
      if [ "''${#stale_dirs[@]}" -gt 1 ]; then
        for (( i=1; i<''${#stale_dirs[@]}; i++ )); do
          rm -rf -- "''${stale_dirs[$i]}"
        done
      fi
    '';
  };

  installerRuntimeCondition = ''
    [ -e ${command [ managedMarker ]} ] \
      || /usr/bin/grep -Fq '/usr/local/libexec/darwin/' "/Library/LaunchDaemons/${storeLabel}.plist" 2>/dev/null
  '';

  verifyHandbackScript = pkgs.writeShellApplication {
    name = "determinate-verify-handback";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      if ${installerRuntimeCondition}; then
        ${lib.concatMapStringsSep "\n"
          (
            path:
            failIf "[[ ! -x ${command [ path ]} ]]" "cannot restore the installer runtime, missing executable: ${path}"
          )
          [
            "/usr/local/bin/determinate-nixd"
            "/nix/var/nix/profiles/default/bin/nix"
            "/nix/var/nix/profiles/default/bin/nix-daemon"
          ]
        }
      fi
    '';
  };

  checkHandbackDaemon = mkCheckDaemonScript "determinate-check-installer-daemon" "/nix/var/nix/profiles/default/bin";

  handbackScript = pkgs.writeShellApplication {
    name = "determinate-handback";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      ${launchdHelpers}

      if ${installerRuntimeCondition}; then
        /usr/local/bin/determinate-nixd --nix-bin /nix/var/nix/profiles/default/bin \
          init --stop-after nix-configuration

        if /bin/launchctl print system/${hookLabel} >/dev/null 2>&1; then
          launchd_bootout system/${hookLabel}
        fi
        if /bin/launchctl print system/${daemonLabel} >/dev/null 2>&1; then
          launchd_bootout system/${daemonLabel}
        fi

        install_plist ${command [ ./installer/store.plist ]} "/Library/LaunchDaemons/${storeLabel}.plist"
        install_plist ${
          command [ ./installer/daemon.plist ]
        } "/Library/LaunchDaemons/${daemonLabel}.plist"
        install_plist ${command [ ./installer/hook.plist ]} "/Library/LaunchDaemons/${hookLabel}.plist"

        /bin/launchctl enable system/${daemonLabel}
        /bin/launchctl bootstrap system "/Library/LaunchDaemons/${daemonLabel}.plist"
        /bin/launchctl enable system/${hookLabel}
        /bin/launchctl bootstrap system "/Library/LaunchDaemons/${hookLabel}.plist"

        rm -f -- ${
          command [
            managedMarker
            customConfStamp
            configPath
          ]
        }
        ${lib.getExe checkHandbackDaemon}
      fi
    '';
  };
in
{
  options.determinateNix = {
    enable = lib.mkEnableOption ''
      declarative Determinate Nix binaries, Nixd, and launchd services on an
      existing Determinate installation. Disabling it restores the installer
      services and runtime from /usr/local/bin/determinate-nixd
    '';

    package = lib.mkOption {
      type = t.package;
      default = inputs.determinate.inputs.nix.packages.${system}.default;
      defaultText = lib.literalExpression "inputs.determinate.inputs.nix.packages.\${pkgs.stdenv.hostPlatform.system}.default";
      description = "Determinate Nix package selected by the pinned Determinate flake input.";
    };

    daemon.package = lib.mkOption {
      type = t.package;
      default = inputs.determinate.packages.${system}.default;
      defaultText = lib.literalExpression "inputs.determinate.packages.\${pkgs.stdenv.hostPlatform.system}.default";
      description = "Determinate Nixd package used for both daemon execution and early-boot store init.";
    };

    customSettings = lib.mkOption {
      type = t.attrsOf (t.nullOr (t.either atom (t.listOf atom)));
      default = { };
      description = "Settings written to /etc/nix/nix.custom.conf and validated at build time.";
    };

    determinateNixd = lib.mkOption {
      type = nixdType;
      default = { };
      description = "JSON configuration for Determinate Nixd written to /etc/determinate/config.json.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = lib.all (
            name:
            builtins.match "[a-zA-Z][a-zA-Z0-9-]*" name != null
            && !builtins.elem (lib.removePrefix "extra-" name) reserved
            && builtins.match "[^\r\n#]*" (valueString settings.${name}) != null
          ) (builtins.attrNames settings);
          message = "determinateNix.customSettings requires single-line setting names and values and must not override Nixd-managed settings";
        }
        {
          assertion = !(cfg.determinateNixd ? telemetry && cfg.determinateNixd.telemetry ? sentry);
          message = "determinateNix: telemetry.sentry was removed upstream in Determinate 3.24.3; omit it";
        }
      ];

      nix.enable = lib.mkForce false;

      environment = {
        systemPackages = [
          cfg.package
          cfg.daemon.package
        ];
        # determinate/config.json is installed as a real file by postActivation (see configPath);
        # an /etc/static symlink is unreadable at boot before /nix mounts.
        etc."nix/nix.custom.conf".source = customConfig;
      };

      system.activationScripts = {
        checks.text = lib.getExe verifyEnabledScript;
        postActivation.text = lib.getExe activateEnabledScript;
      };
    })

    (lib.mkIf (!cfg.enable) {
      system.activationScripts = {
        checks.text = lib.getExe verifyHandbackScript;
        postActivation.text = lib.getExe handbackScript;
      };
    })
  ];
}
