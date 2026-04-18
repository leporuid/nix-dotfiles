{ pname, pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  inherit pname;
  version = "main";

  src = pkgs.fetchFromGitHub {
    owner = "raviqqe";
    repo = pname;
    rev = "main";
    hash = "sha256-JXlaOMlBn3rZtNHLbzXNp4a6w/BaFdzWjgY2MdbWJtA=";
  };

  # FIXME: This should really be removed in favor of using a proper nightly
  # toolchain, but it works for now. Might need to use rust-overlay?
  env.RUSTC_BOOTSTRAP = true;

  cargoHash = "sha256-lIy71FOYg3VJvl7F/6MtPI8ejHHadJloJdPBEnm0aBM=";

  meta = {
    description = "Code formatter for Scheme, Lisp, and any S-expressions";
    homepage = "github.com/raviqqe/schemat";
    license = pkgs.lib.licenses.unlicense;
    maintainers = [ ];
  };
}