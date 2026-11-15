{ pkgs, pname, ... }:
with pkgs;
rustPlatform.buildRustPackage {
  inherit pname;
  version = "main";

  src = fetchFromGitHub {
    owner = "raviqqe";
    repo = pname;
    rev = "a0b0031c5bf6e1d4e2dc2fdd0f55b61a5b77be61";
    hash = "sha256-LpcgQU32KCtFGhRhHyh9k8itdooWS6qhr3G6fUsmixk=";
  };

  # FIXME: This should really be removed in favor of using a proper nightly
  # toolchain, but it works for now. Might need to use rust-overlay?
  env.RUSTC_BOOTSTRAP = true;

  cargoHash = "sha256-x2QOt/rsFcRz1nNle+qcxOx1UN7fzXhohQ6cpWJMvcw=";

  meta = {
    description = "Code formatter for Scheme, Lisp, and any S-expressions";
    homepage = "github.com/raviqqe/schemat";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}
