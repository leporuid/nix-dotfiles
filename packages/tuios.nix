{ lib, pkgs, ... }:
pkgs.buildGo127Module (finalAttrs: {
  pname = "tuios";
  version = "0.13.3";

  src = pkgs.fetchFromGitHub {
    owner = "Gaurav-Gosain";
    repo = "tuios";
    tag = "v${finalAttrs.version}";
    hash = "sha256-K5HdrurAchfL8OCLTXRej+s7EjYhicoFgKlFdKQaeP0=";
  };

  # Only build the main binaries; e2e/ and other packages carry //go:build e2e tags.
  subPackages = [
    "cmd/tuios"
    "cmd/tuios-web"
  ];

  # Keep Go from attempting network toolchain downloads inside the Nix build sandbox.
  env.GOTOOLCHAIN = "local";

  nativeCheckInputs = [ pkgs.git ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.builtBy=nix"
  ];

  # Drop e2e/tui from go.work so its test-only dependencies stay out of vendorHash.
  postPatch = ''
    go work edit -dropuse=./e2e/tui
  '';

  modBuildPhase = ''
    runHook preBuild
    go work vendor
    runHook postBuild
  '';

  vendorHash = "sha256-9YBbr0IumNyL9o5i3R2HQ2pAcq35FHkH5PlucOITLPA=";

  meta = {
    description = "Terminal UI operating system and multiplexer";
    homepage = "https://github.com/Gaurav-Gosain/tuios";
    license = lib.licenses.mit;
    mainProgram = "tuios";
    maintainers = [ ];
  };
})
