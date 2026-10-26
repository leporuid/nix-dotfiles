{ pkgs, inputs, ... }:
(pkgs.n-m3u8dl-re.override {
  buildDotnetModule =
    args:
    pkgs.buildDotnetModule (
      finalAttrs:
      (args finalAttrs)
      // {
        dotnet-sdk = pkgs.dotnetCorePackages.sdk_9_0;
        dotnet-runtime = pkgs.dotnetCorePackages.runtime_9_0;

        projectFile = "src/N_m3u8DL-RE/N_m3u8DL-RE.csproj";
        doCheck = false;
      }
    );
}).overrideAttrs
  (old: {
    version = "0.0.0-unstable-${inputs.n-m3u8dl-re.shortRev or "dirty"}";

    src = inputs.n-m3u8dl-re;

    nugetDeps = ../overlays/n-m3u8dl-re-deps.json;
    patches = [ ];

    postPatch = (old.postPatch or "") + ''
      find . -type f \( -name "*.csproj" -o -name "*.props" \) -exec sed -i 's/net10\.0/net9.0/g' {} +
      find . -type f \( -name "*.csproj" -o -name "*.props" \) -exec sed -i 's/<PublishTrimmed>true<\/PublishTrimmed>//g' {} +
      find . -type f \( -name "*.csproj" -o -name "*.props" \) -exec sed -i 's/<PublishAot>true<\/PublishAot>//g' {} +
      find . -type f \( -name "*.csproj" -o -name "*.props" \) -exec sed -i 's/<PublishSingleFile>true<\/PublishSingleFile>//g' {} +

      rm -f src/N_m3u8DL-RE.sln
      rm -rf src/N_m3u8DL-RE.Tests
    '';

    postFixup = (old.postFixup or "") + (pkgs.callPackage ./m3u8dl-protocol { }).injectHook;
  })
