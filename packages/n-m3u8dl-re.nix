{ pname, pkgs, ... }:
with pkgs;
buildDotnetModule rec {
  inherit pname;
  version = "main";

  src = fetchFromGitHub {
    owner = "nilaoda";
    repo = pname;
    rev = "main";
    # ⚠️ 因為程式碼來源變了，請先使用全 0 假 Hash 讓 Nix 報錯並給出正確的新 Hash
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  projectFile = "src/N_m3u8DL-RE/N_m3u8DL-RE.csproj";

  # ⚠️ 原始碼變更可能導致 NuGet 依賴變更，這份檔案需要重新產生
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ ffmpeg ]}"
  ];

  meta = with lib; {
    description = "Cross-Platform, modern and powerful stream downloader for MPD/HLS/ISM";
    homepage = "https://github.com/nilaoda/N_m3u8DL-RE";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "N_m3u8DL-RE";
    platforms = platforms.all;
  };
}