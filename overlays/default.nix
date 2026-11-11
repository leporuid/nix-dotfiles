# overlays/default.nix — nixpkgs overlays applied to every host.
#
# This is a list of standard `final: prev:` overlays, consumed by flake.nix
# (via blueprint's nixpkgs.overlays) to apply workarounds across all hosts, packages, and devshells.
inputsOrArgs:
let
  inputs =
    if builtins.isAttrs inputsOrArgs && inputsOrArgs ? inputs then
      inputsOrArgs.inputs
    else if builtins.isAttrs inputsOrArgs && inputsOrArgs ? determinate then
      inputsOrArgs
    else
      null;
in
[
  # Determinate Nix overrides (from malob/nix-config):
  # Ensure tools calling `nix` (comma, nix-update, nixpkgs-review) use Determinate Nix
  # instead of pulling upstream nixpkgs nix closure.
  (
    _final: prev:
    let
      system = prev.stdenv.hostPlatform.system;
      determinateNix =
        if inputs != null then
          (inputs.determinate.inputs.nix.packages.${system}.default
            or inputs.determinate.packages.${system}.default or null
          )
        else
          null;
    in
    prev.lib.optionalAttrs (determinateNix != null) {
      comma = prev.comma.override { nix = determinateNix; };
      nix-update = prev.nix-update.override { nix = determinateNix; };
      nixpkgs-review = prev.nixpkgs-review.override { nix = determinateNix; };
    }
  )

  # curl-impersonate 2.1.0 sets its macOS dylib install_name to the relative
  # `@rpath/libcurl-impersonate.4.dylib` rather than the absolute store path.
  # Nothing in the build adds a matching -rpath, so consumers that link it —
  # python3Packages.curl-cffi, and through it yt-dlp — fail to load with
  # "Library not loaded: @rpath/libcurl-impersonate.4.dylib ... no LC_RPATH's
  # found". Version 1.5.6 used the absolute store path and worked; the 2.x
  # bump regressed it.
  #
  # Rewriting the id back to the store path is the convention for darwin
  # dylibs in nixpkgs, and fixes every consumer at once rather than patching
  # each one to carry an rpath.
  (
    _final: prev:
    prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
      curl-impersonate = prev.curl-impersonate.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          for f in "$out"/lib/libcurl-impersonate*.dylib; do
            # lib/ also holds version symlinks (libcurl-impersonate.4.dylib ->
            # libcurl-impersonate.4.8.0.dylib); only the real Mach-O has an id.
            [ -L "$f" ] || install_name_tool -id "$f" "$f"
          done
        '';
      });
    }
  )

  # curl-cffi's test suite has four darwin-only failures that are test bugs,
  # not packaging bugs (367 other tests pass):
  #
  #   * test_verify (x3, in test_async_session/test_curl/test_requests) asserts
  #     on the string "SSL certificate problem", but the LibreSSL-backed curl
  #     on darwin words the same error as "no alternative certificate subject
  #     name matches target ipv4 address '127.0.0.1'".
  #   * test_delete_cookies leaves a cookie set on the 127.0.0.1 test server.
  #
  # These only became visible once the install_name fix above let the build get
  # past pythonImportsCheck. Upstream already disables a batch of similar
  # network/TLS-sensitive tests in this derivation; this extends that list.
  (
    _final: prev:
    prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (_pyfinal: pyprev: {
          curl-cffi = pyprev.curl-cffi.overrideAttrs (old: {
            disabledTests = (old.disabledTests or [ ]) ++ [
              "test_verify"
              "test_delete_cookies"
            ];
          });
        })
      ];
    }
  )
]
