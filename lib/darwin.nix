# lib/darwin.nix — macOS specific declarative activation and application sync helpers
_: {
  # Generates an APFS clone activation script snippet to copy an application from the Nix store to /Applications
  # This ensures Spotlight, LaunchServices, and the macOS Dock register the app natively without symlink failures.
  mkAppCloneScript = appPath: ''
    if [ -d "${appPath}" ]; then
      _appName="$(basename "${appPath}")"
      rm -rf "/Applications/$_appName"
      /bin/cp -cR "${appPath}" "/Applications/$_appName" 2>/dev/null || /bin/cp -R "${appPath}" "/Applications/$_appName"
      chmod -R u+w "/Applications/$_appName"
    fi
  '';

  # Syncs Nix-managed .app bundles into targetDir via rsync without disturbing unmanaged applications.
  # Dereferences top-level store links via linkFarm while preserving internal symlinks and verifying write access first.
  mkAppSyncScript =
    {
      pkgs,
      apps,
      targetDir ? "/Applications",
    }:
    let
      inherit (pkgs) lib;
      appEntries = map (appPath: {
        name = builtins.unsafeDiscardStringContext (builtins.baseNameOf (toString appPath));
        path = appPath;
      }) apps;
      appFarm = pkgs.linkFarm "darwin-applications" appEntries;
      appNameArgs = lib.concatMapStringsSep " " (entry: lib.escapeShellArg entry.name) appEntries;
      syncScript = pkgs.writeShellApplication {
        name = "darwin-sync-applications";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.rsync
        ];
        text = ''
          target_dir=${lib.escapeShellArg targetDir}
          source_dir="${appFarm}"
          mkdir -p "$target_dir"

          probe_write() {
            local dir="$1"
            local probe
            probe="$(mktemp --tmpdir="$dir" .darwin-app-probe.XXXXXXXX)"
            rm -f -- "$probe"
          }

          probe_write "$target_dir"

          work_dir="$(mktemp -d)"
          trap 'rm -rf -- "$work_dir"' EXIT
          printf '%s\0' ${appNameArgs} > "$work_dir/names"

          while IFS= read -r -d "" app_name; do
            target_app="$target_dir/$app_name"
            if [ -L "$target_app" ]; then
              rm -f -- "$target_app"
            elif [ -d "$target_app" ]; then
              probe_write "$target_app"
            elif [ -e "$target_app" ]; then
              echo "darwin-sync-applications: refusing to overwrite non-directory $target_app" >&2
              exit 1
            fi
          done < "$work_dir/names"

          chown_args=()
          if [ "$(id -u)" -eq 0 ]; then
            chown_args=(--owner --group --chown=0:0)
          fi

          rsync \
            --recursive \
            --links \
            --perms \
            --specials \
            --checksum \
            --copy-unsafe-links \
            --delete-delay \
            --delete-missing-args \
            --force \
            --from0 \
            --no-implied-dirs \
            --chmod=-w \
            ''${chown_args[@]+"''${chown_args[@]}"} \
            --files-from="$work_dir/names" \
            -- "$source_dir/" "$target_dir/"
        '';
      };
    in
    lib.optionalString (apps != [ ]) (lib.getExe syncScript);
}
