# overlays/default.nix — nixpkgs overlays applied to every host.
#
# This is a list of standard `final: prev:` overlays, consumed by host modules
# and exposed via `flake.overlays.default`.
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
  # Rewriting the id back to the store path fixes consumers such as curl-cffi and yt-dlp.
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

  # Disable flaky darwin-only network/TLS tests in curl-cffi.
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
