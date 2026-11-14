# lib/darwin.nix — macOS specific declarative activation and trampoline helpers
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
}
