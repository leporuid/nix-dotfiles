{ pname, pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  inherit pname;
  version = "main";

  src = pkgs.fetchFromGitHub {
    owner = "raviqqe";
    repo = pname;
    rev = "main";
    hash = "sha256-AQtmcWltKhlfWJk9Lu3NptJOHfxsGxhC58uTfd4oIKw=";
  };

  # FIXME: This should really be removed in favor of using a proper nightly
  # toolchain, but it works for now. Might need to use rust-overlay?
  env.RUSTC_BOOTSTRAP = true;

  cargoHash = "sha256-0upXhF7Ft133oVY3zPYjPgo9iuHoeJSvien+Uc0mzFg=";

  meta = {
    description = "Code formatter for Scheme, Lisp, and any S-expressions";
    homepage = "github.com/raviqqe/schemat";
    license = pkgs.lib.licenses.unlicense;
    maintainers = [ ];
  };
}