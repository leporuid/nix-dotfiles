{ pname, pkgs, ... }:
with pkgs;
rustPlatform.buildRustPackage {
  inherit pname;
  version = "main";

  src = fetchFromGitHub {
    owner = "raviqqe";
    repo = pname;
    rev = "main";
    hash = "sha256-tS60Ix1U9HSM/T551RLJBRrs8hkfZiG51ztTX0qgXOU=";
  };

  # FIXME: This should really be removed in favor of using a proper nightly
  # toolchain, but it works for now. Might need to use rust-overlay?
  env.RUSTC_BOOTSTRAP = true;

  cargoHash = "sha256-KTp26PKEVu0yvclIytX8o4kIhFW4ZVm7Pqss/aWQMWw=";

  meta = {
    description = "Code formatter for Scheme, Lisp, and any S-expressions";
    homepage = "github.com/raviqqe/schemat";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}
