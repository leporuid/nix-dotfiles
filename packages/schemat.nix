{ pname, pkgs, ... }:
with pkgs;
rustPlatform.buildRustPackage {
  inherit pname;
  version = "main";

  src = fetchFromGitHub {
    owner = "raviqqe";
    repo = pname;
    rev = "main";
    hash = "sha256-DxRm9lfBMw6yj4eU2SW5WUnNZ7BNUHgfQx0xXWr0XwA=";
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
