{ lib, pkgs, ... }:

let
  duForTests = pkgs.writeShellScriptBin "du" ''
    args=()
    while (( $# > 0 )); do
      case "$1" in
        -I)
          shift
          args+=("--exclude=$1")
          ;;
        *)
          args+=("$1")
          ;;
      esac
      shift
    done

    exec ${lib.getExe' pkgs.coreutils "du"} "''${args[@]}"
  '';
in
pkgs.buildGo127Module (finalAttrs: {
  pname = "mole-cleaner";
  version = "1.72.0";

  src = pkgs.fetchFromGitHub {
    owner = "tw93";
    repo = "Mole";
    tag = "V${finalAttrs.version}";
    hash = "sha256-pNRp7GnjfqEWyiEmHqHagzJagzZDpU/6oeLHc6wWiB8=";
  };

  vendorHash = "sha256-OQ7QTSuulopAS+2Jet2roZVGPMXgJUav73du+MJlt6o=";

  __structuredAttrs = true;

  env.CGO_ENABLED = 0;

  postPatch = ''
    # The cancellation test stub blocks on `tail`, unreachable at /usr/bin
    # inside the Darwin sandbox. PATH resolves the stdenv coreutils one.
    substituteInPlace cmd/analyze/analyze_test.go \
      --replace-fail '/usr/bin/tail' 'tail'

    substituteInPlace mole \
      --replace-fail '/bin/pwd' 'pwd' \
      --replace-fail 'update_message="$(read_update_message_cache "$msg_cache")"' 'update_message=""'
  '';

  buildInputs = [
    pkgs.bash
  ];

  nativeBuildInputs = [
    pkgs.installShellFiles
    pkgs.makeWrapper
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  nativeCheckInputs = [
    duForTests
  ];

  # No usable /usr/bin/ps or /Users directory inside the Darwin build sandbox.
  checkFlags = [
    "-skip=AcceptsCurrentDarwinOutput|CollectProcessesUnderCommaLocale|TestValidateTrashTargetRejectsCriticalRoots"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 mole $out/libexec/mole/mole
    cp -r bin lib $out/libexec/mole/

    install -Dm755 $GOPATH/bin/analyze $out/libexec/mole/bin/analyze-go
    install -Dm755 $GOPATH/bin/status $out/libexec/mole/bin/status-go

    makeWrapper $out/libexec/mole/mole $out/bin/mo \
      --prefix PATH : '/bin' \
      --prefix PATH : '/usr/bin' \
      --prefix PATH : ${
        lib.makeBinPath [
          pkgs.fd
        ]
      } \
      --run '
        case "$1" in
          update|remove)
            echo "mo $1 is unsupported for Nix-installed Mole; update or remove it through nix-dotfiles." >&2
            exit 1
            ;;
        esac
      '

    runHook postInstall
  '';

  postFixup = lib.optionalString (pkgs.stdenv.buildPlatform.canExecute pkgs.stdenv.hostPlatform) ''
    installShellCompletion --cmd mo \
      --bash <($out/bin/mo completion bash) \
      --fish <($out/bin/mo completion fish) \
      --zsh <($out/bin/mo completion zsh)
  '';

  nativeInstallCheckInputs = [
    pkgs.versionCheckHook
    pkgs.writableTmpDirAsHomeHook
  ];

  doInstallCheck = true;
  versionCheckKeepEnvironment = "HOME PATH";
  versionCheckProgram = "${placeholder "out"}/bin/mo";

  meta = {
    description = "CLI tool for cleaning and optimizing macOS systems";
    homepage = "https://github.com/tw93/Mole";
    changelog = "https://github.com/tw93/Mole/releases/tag/V${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "mo";
    platforms = lib.platforms.darwin;
  };
})
