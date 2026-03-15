{ pname, pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  inherit pname;
  version = "0.5.1";
  
  src = pkgs.fetchFromGitHub {
    owner = "rutrum";
    repo = pname;
    rev = "4542911256deee7a5bca7e20778f5ef81c20c121";
    hash = "sha256-5STKMFvCfB4yOV9jCJGDux4AfwbdWOBi8f7UV6s8TqA=";
  };
  cargoHash = "sha256-gi7CR5UUD+qUQ6wx0XepzyHHq9RH7SnsMXIKV4JoiQg=";

  meta = {
    description = "Command line interface to convert strings into any case";
    homepage = "https://github.com/rutrum/ccase";
    license = pkgs.lib.licenses.mit;
    maintainers = [ ];
  };
}