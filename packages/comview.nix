{ pname, pkgs, ... }:
pkgs.buildGoModule {
  inherit pname;
  version = "0-unstable-2026-09-16";
  src = pkgs.fetchFromGitHub {
    owner = "rockorager";
    repo = "comview";
    rev = "main";
    hash = "sha256-9mkRE8zycbXkeWRV5QJErhNSX850ywcpZBjpaSTLuJo=";
  };
  vendorHash = "sha256-f7Q4+Bd22xnxkOWjgv4TzPmgZTNHhYvMtoVyl9anGzc=";

  meta = {
    description = "The best diff viewer ever made";
    homepage = "https://github.com/rockorager/comview";
    license = pkgs.lib.licenses.mit;
    mainProgram = "comview";
    maintainers = [ ];
  };
}
