# Darwin Zed Nightly derivation adapted from HaukurPall/zed with prebuilt libghostty-vt 1.0.1.
{
  lib,
  pkgs,
  apple-sdk_26,
  cargo-about,
  cargo-bundle,
  cmake,
  copyDesktopItems,
  crane,
  curl,
  darwinMinVersionHook,
  fetchFromGitHub,
  fetchurl,
  fontconfig,
  freetype,
  git,
  libgit2,
  lld,
  makeFontsConf,
  openssl,
  perl,
  pkg-config,
  protobuf,
  runCommand,
  rustPlatform,
  rustToolchain,
  sqlite,
  srcRoot,
  stdenv,
  unzip,
  zlib,
  zstd,
  commitSha ? null,
  profile ? "release",
  withGhostty ? stdenv.hostPlatform.isDarwin,
}:
assert withGhostty -> stdenv.hostPlatform.isDarwin;
let
  mkIncludeFilter =
    root': path: _type:
    let
      root = toString root' + "/";
      relPath = lib.removePrefix root path;
      topLevelIncludes = [
        "crates"
        "assets"
        "extensions"
        "script"
        "tooling"
        "Cargo.toml"
        ".config"
        ".cargo"
      ];
      firstComp = builtins.head (lib.path.subpath.components relPath);
    in
    builtins.elem firstComp topLevelIncludes;

  corgiPatches = builtins.path {
    path = "${srcRoot}/tooling/corgi/patches";
    name = "corgi-patches";
  };
  craneLib = crane.overrideToolchain rustToolchain;

  # Prebuilt static archive + headers for libghostty-vt (vt-1.0.1),
  # avoiding network git clone + Zig 0.17 inside Nix sandbox.
  libghostty-vt =
    runCommand "libghostty-vt-1.0.1-macos"
      {
        src = fetchurl {
          url = "https://release.files.ghostty.org/libghostty-vt/1.0.1/ghostty-vt-1.0.1.xcframework.zip";
          hash = "sha256-wPljEnf3JhVMj1IZVNF83EGqxGJvwN+M+SWhnuWOgps=";
        };
        nativeBuildInputs = [ unzip ];
      }
      ''
        unzip -q "$src"
        slice=ghostty-vt.xcframework/macos-arm64_x86_64
        mkdir -p "$out/lib/pkgconfig" "$out/include"
        cp "$slice/libghostty-vt.a" "$out/lib/"
        cp -R "$slice/Headers/." "$out/include/"
        cat > "$out/lib/pkgconfig/libghostty-vt-static.pc" <<EOF
        prefix=$out
        libdir=\''${prefix}/lib
        includedir=\''${prefix}/include

        Name: libghostty-vt-static
        Description: Ghostty VT library (static)
        Version: 1.0.1
        Libs: -L\''${libdir} -lghostty-vt
        Cflags: -I\''${includedir}
        EOF
      '';

  zedCargoToml = builtins.fromTOML (builtins.readFile "${srcRoot}/crates/zed/Cargo.toml");
  version =
    zedCargoToml.package.version
    + "-nightly"
    + lib.optionalString (commitSha != null) "+${builtins.substring 0 7 commitSha}";
  src = builtins.path {
    path = srcRoot;
    filter = mkIncludeFilter srcRoot;
    name = "source";
  };
  cargoLock = "${srcRoot}/Cargo.lock";
  stdenv' = stdenv;

  commonArgs = {
    inherit cargoLock src version;
    pname = "zed-editor";

    nativeBuildInputs = [
      cmake
      copyDesktopItems
      curl
      lld
      perl
      pkg-config
      protobuf
      rustPlatform.bindgenHook
      # Pin cargo-about to 0.8.2; newer versions reject upstream license identifiers.
      (cargo-about.overrideAttrs (
        new: _old:
        let
          aboutVersion = "0.8.2";
          aboutSrc = fetchFromGitHub {
            owner = "EmbarkStudios";
            repo = "cargo-about";
            tag = aboutVersion;
            sha256 = "sha256-cNKZpDlfqEXeOE5lmu79AcKOawkPpk4PQCsBzNtIEbs=";
          };
          aboutCargoHash = "sha256-NnocSs6UkuF/mCM3lIdFk+r51Iz2bHuYzMT/gEbT/nk=";
        in
        {
          version = aboutVersion;
          src = aboutSrc;
          cargoHash = aboutCargoHash;
          cargoBuildFeatures = [ ];
          cargoCheckFeatures = [ ];
          cargoDeps = rustPlatform.fetchCargoVendor {
            src = aboutSrc;
            hash = aboutCargoHash;
            patches = new.cargoPatches or [ ];
            name = new.cargoDepsName or new.finalPackage.name;
          };
        }
      ))
      (cargo-bundle.overrideAttrs (
        new: _old:
        let
          bundleSrc = fetchFromGitHub {
            owner = "zed-industries";
            repo = "cargo-bundle";
            rev = "2be2669972dff3ddd4daf89a2cb29d2d06cad7c7";
            hash = "sha256-cSvW0ND148AGdIGWg/ku0yIacVgW+9f1Nsi+kAQxVrI=";
          };
          bundleCargoHash = "sha256-urn+A3yuw2uAO4HGmvQnKvWtHqvG9KHxNCCWTiytE4k=";
        in
        {
          version = "0.6.1-zed";
          src = bundleSrc;
          cargoHash = bundleCargoHash;
          cargoDeps = rustPlatform.fetchCargoVendor {
            src = bundleSrc;
            hash = bundleCargoHash;
            patches = new.cargoPatches or [ ];
            name = new.cargoDepsName or new.finalPackage.name;
          };
        }
      ))
    ];

    buildInputs = [
      apple-sdk_26
      curl
      fontconfig
      freetype
      libgit2
      openssl
      sqlite
      zlib
      zstd
      (darwinMinVersionHook "12.0")
    ]
    ++ lib.optionals withGhostty [ libghostty-vt ];

    cargoExtraArgs =
      "-p zed -p cli"
      + lib.optionalString withGhostty " -p terminal"
      + " --locked --features=gpui_platform/runtime_shaders"
      + lib.optionalString withGhostty ",terminal/ghostty";

    stdenv = pkgs': pkgs'.llvmPackages.stdenv;

    env = {
      ZSTD_SYS_USE_PKG_CONFIG = true;
      FONTCONFIG_FILE = makeFontsConf {
        fontDirectories = [
          "${srcRoot}/assets/fonts/lilex"
          "${srcRoot}/assets/fonts/ibm-plex-sans"
        ];
      };
      ZED_UPDATE_EXPLANATION = "Zed has been installed using Nix. Auto-updates have thus been disabled.";
      RELEASE_VERSION = version;
      ZED_COMMIT_SHA = lib.optionalString (commitSha != null) commitSha;
      LK_CUSTOM_WEBRTC = pkgs.livekit-libwebrtc;
      PROTOC = "${protobuf}/bin/protoc";

      CARGO_PROFILE = profile;
      TARGET_DIR = "target/" + (if profile == "dev" then "debug" else profile);

      # Link with lld on Darwin to avoid classic ld64 ARM64 branch out-of-range errors.
      NIX_CFLAGS_LINK = "-fuse-ld=lld";
      NIX_OUTPATH_USED_AS_RANDOM_SEED = "norebuilds";
    }
    // lib.optionalAttrs withGhostty {
      ZED_LIBGHOSTTY_VT_DIR = "${libghostty-vt}";
    };

    dontPatchELF = stdenv'.hostPlatform.isLinux;
    doCheck = false;

    cargoVendorDir = craneLib.vendorCargoDeps {
      inherit cargoLock src;
      overrideVendorGitCheckout =
        let
          hasWebRtcSys = builtins.any (crate: crate.name == "webrtc-sys");
          hasLibGhosttyVtSys = builtins.any (crate: crate.name == "libghostty-vt-sys");

          postPatch = ''
            substituteInPlace webrtc-sys/build.rs --replace-fail \
              "cargo:rustc-link-lib=static=webrtc" "cargo:rustc-link-lib=dylib=webrtc"

            substituteInPlace webrtc-sys/build.rs --replace-fail \
              'add_gio_headers(&mut builder);' \
              'for lib_name in ["glib-2.0", "gio-2.0"] {
                  if let Ok(lib) = pkg_config::Config::new().cargo_metadata(false).probe(lib_name) {
                      for path in lib.include_paths {
                          builder.include(&path);
                      }
                  }
              }'
          '';

          # Link libghostty-vt-sys against the prebuilt static archive inside the Nix sandbox.
          ghosttyPostPatch = ''
            substituteInPlace crates/libghostty-vt-sys/build.rs \
              --replace-fail \
                'println!("cargo:rerun-if-env-changed=GHOSTTY_SOURCE_DIR");' \
                'println!("cargo:rerun-if-env-changed=ZED_LIBGHOSTTY_VT_DIR");
            println!("cargo:rerun-if-env-changed=GHOSTTY_SOURCE_DIR");' \
              --replace-fail \
                'if env::var_os("GHOSTTY_SOURCE_DIR").is_some() {' \
                'if let Ok(prebuilt_dir) = env::var("ZED_LIBGHOSTTY_VT_DIR") {
                    let prebuilt_dir = PathBuf::from(prebuilt_dir);
                    let include_dir = prebuilt_dir.join("include");
                    assert!(
                        include_dir.join("ghostty").join("vt.h").exists(),
                        "expected header at {}",
                        include_dir.join("ghostty").join("vt.h").display()
                    );
                    println!(
                        "cargo:rustc-env=LIBGHOSTTY_VT_SYS_INCLUDE_DIR={}",
                        include_dir.display()
                    );
                    println!(
                        "cargo:rustc-link-search=native={}",
                        prebuilt_dir.join("lib").display()
                    );
                    emit_static_link_lib(&target);
                    emit_include_metadata(&[include_dir]);
                    return;
                }

                if env::var_os("GHOSTTY_SOURCE_DIR").is_some() {'
          '';
        in
        crates: drv:
        let
          patchedForWebRtc =
            if hasWebRtcSys crates then
              drv.overrideAttrs (o: {
                postPatch = (o.postPatch or "") + postPatch;
              })
            else
              drv;
        in
        if withGhostty && hasLibGhosttyVtSys crates then
          patchedForWebRtc.overrideAttrs (o: {
            postPatch = (o.postPatch or "") + ghosttyPostPatch;
          })
        else
          patchedForWebRtc;
    };
  };

  cargoArtifacts = craneLib.buildDepsOnly (
    builtins.removeAttrs commonArgs [ "src" ]
    // {
      dummySrc = craneLib.mkDummySrc {
        inherit (commonArgs) cargoLock src;
        extraDummyScript = ''
          rm -rf $out/tooling/corgi/patches
          mkdir -p $out/tooling/corgi
          cp --recursive ${corgiPatches} $out/tooling/corgi/patches
        '';
      };
    }
  );
in
craneLib.buildPackage (
  lib.recursiveUpdate commonArgs {
    inherit cargoArtifacts;

    passthru = {
      inherit cargoArtifacts commonArgs craneLib;
    }
    // lib.optionalAttrs withGhostty {
      inherit libghostty-vt;
    };

    dontUseCmakeConfigure = true;

    preBuild = ''
      ALLOW_MISSING_LICENSES=yes bash script/generate-licenses
      echo nightly > crates/zed/RELEASE_CHANNEL
    '';

    installPhase = ''
      runHook preInstall

      pushd crates/zed
      sed -i "s/package.metadata.bundle-nightly/package.metadata.bundle/" Cargo.toml
      export CARGO_BUNDLE_SKIP_BUILD=true
      app_path="$(cargo bundle --profile $CARGO_PROFILE | xargs)"
      popd

      mkdir -p "$out/Applications" "$out/bin"
      # Zed expects git next to its own binary.
      ln -s ${git}/bin/git "$app_path/Contents/MacOS/git"
      mv "$TARGET_DIR/cli" "$app_path/Contents/MacOS/cli"
      mv "$app_path" "$out/Applications/"

      # Physical location of the CLI must remain inside the app bundle.
      ln -s "$out/Applications/Zed Nightly.app/Contents/MacOS/cli" "$out/bin/zed"

      runHook postInstall
    '';

    meta = {
      description = "High-performance, multiplayer code editor with libghostty-vt terminal backend";
      homepage = "https://zed.dev";
      changelog = "https://zed.dev/releases/preview";
      license = lib.licenses.gpl3Only;
      mainProgram = "zed";
      platforms = lib.platforms.darwin;
    };
  }
)
