---
name: apple-swift-cocoa-dev
description: Development and Nix packaging guide for Swift, SwiftPM, Xcode SDK, and Objective-C Cocoa targets across ~/Developer/MyLibrary, ~/Developer/Xcode, config/swiftly, packages/age-plugin-se/, and packages/m3u8dl-protocol/. Use when working on Swift 6 packages, Xcode MCP, __noChroot Darwin Nix derivations, or native macOS .app bundles.
---
# Apple, Swift, and Cocoa Development

Covers native Apple/Swift/Objective-C development in `~/Developer/MyLibrary` and `~/Developer/Xcode`, plus Darwin native builds inside `~/Developer/nix-dotfiles/packages/`.

> Native Darwin Nix packages MUST declare `platforms = pkgs.lib.platforms.darwin;` in `meta` so Linux checks never evaluate Darwin-only builds.

## When to Use

- Working in `~/Developer/MyLibrary` (`Package.swift`, Swift 6.2 SwiftPM) or inspecting `~/Developer/Xcode`.
- Modifying `config/swiftly/` or `config/github-copilot/xcode/mcp.json`, or `SWIFTLY_*` variables in `users/leporuid/home-configuration.nix`.
- Maintaining `packages/age-plugin-se/` (SwiftPM + Secure Enclave `__noChroot` build) or `packages/m3u8dl-protocol/` (Objective-C Cocoa `.app` bundle + URL scheme handler).

## SwiftPM & `swiftly` Toolchain

- `~/Developer/MyLibrary/Package.swift` uses `// swift-tools-version: 6.2`.
- Darwin Hjem session variables in `users/leporuid/home-configuration.nix` set `SWIFTLY_HOME_DIR`, `SWIFTLY_BIN_DIR`, and `SWIFTLY_TOOLCHAINS_DIR` (`~/Library/Developer/Toolchains`).
- Keep Xcode MCP settings under `config/github-copilot/xcode/mcp.json` scoped under `isDarwin` in `home-configuration.nix`.

## Impure Xcode SDK Packaging in Nix (`packages/age-plugin-se/`)

When a SwiftPM binary requires Apple Security / CryptoKit / Secure Enclave frameworks unavailable in nixpkgs `swift`:
1. Set `__noChroot = true;` and `NIX_ENFORCE_NO_NATIVE = 0;`.
2. Patch out network-fetched SwiftPM dependencies (`darwin-no-swift-crypto.patch`) and `rm -f Package.resolved` in `postPatch` so `swift build` stays offline.
3. Probe full `Xcode.app` (`xcodebuild` marker, falling back from Command Line Tools to `/Applications/Xcode.app/Contents/Developer`), export `DEVELOPER_DIR` and `SDKROOT=$(/usr/bin/xcrun --sdk macosx --show-sdk-path)`.
4. Compile with `/usr/bin/xcrun swift build -c release --disable-sandbox -Xcc -O3 -Xswiftc -cross-module-optimization -Xswiftc -Xfrontend -Xswiftc -disable-availability-checking`.

## Pure-Nix Objective-C Cocoa `.app` Bundles (`packages/m3u8dl-protocol/`)

- Keep the native Objective-C implementation (`main.m`) compiled directly with `pkgs.apple-sdk` (`$CC -framework Cocoa`) — do not rewrite to Swift/Electron if pure-Nix sandbox reproducibility is desired.
- Whitelist `main.m`, `Info.plist`, and `AppIcon.icns` via `pkgs.lib.fileset.toSource`.
- `passthru.injectHook` wraps consumer binaries (such as `packages/n-m3u8dl-re`) to lazily register `M3U8DLProtocol.app` with LaunchServices (`lsregister -f`) keyed by a store-path stamp in `$HOME/.cache/n-m3u8dl-re/registered_path`.
- System installation into `/Applications` happens via `lib.darwin.mkAppSyncScript` in `modules/darwin/applications.nix` (`rsync`, not symlinks).

## Verification

- SwiftPM targets: `swift build` / `swift test` inside the Swift package root.
- Nix Darwin derivations (on `aarch64-darwin`):
  ```fish
  nix build .#age-plugin-se --no-link
  nix build .#m3u8dl-protocol --no-link
  ```
