{ pname, pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  inherit pname;
  version = "main";

  src = pkgs.fetchFromGitHub {
    owner = "raviqqe";
    repo = pname;
    rev = "main";
    hash = "sha256-BrAlaERQCg0IO4tw7b1q3DjR3o2/YiOWF3QojquSmCA=";
  };

  # FIXME: This should really be removed in favor of using a proper nightly
  # toolchain, but it works for now. Might need to use rust-overlay?
  env.RUSTC_BOOTSTRAP = true;

  cargoHash = "sha256-z/tNO6DRA/0xXo8DdCdpgiLlcm4FCEV7YK93yViY/Bo=";

  meta = {
    description = "Code formatter for Scheme, Lisp, and any S-expressions";
    homepage = "github.com/raviqqe/schemat";
    license = pkgs.lib.licenses.unlicense;
    maintainers = [ ];
  };
}