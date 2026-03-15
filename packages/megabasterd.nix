{ pname, pkgs, ... }:
pkgs.maven.buildMavenPackage {
  inherit pname;
  version = "8.22";

  src = pkgs.fetchFromGitHub {
    owner = "tonikelope";
    repo = pname;
    rev = "master";
    hash = "sha256-KNZ8to5PNQbDcRswoE/rL6MgPjYFguT0e2/RHbK2IPw=";
  };

  mvnHash = "sha256-b7+17CXmBB65fMG472FPjOvr+9nAsUurdBC/7esalCE=";

  nativeBuildInputs = with pkgs; [ makeWrapper ];

  installPhase = with pkgs; ''
    runHook preInstall

    jar_filename=MegaBasterd-${version}-jar-with-dependencies.jar

    mkdir -p $out/bin $out/share/megabasterd
    install -Dm644 target/$jar_filename $out/share/megabasterd

    makeWrapper ${jre}/bin/java $out/bin/megabasterd \
      --add-flags "-jar $out/share/megabasterd/$jar_filename"

    runHook postInstall
  '';

  meta = {
    description = "Yet another unofficial (and ugly) cross-platform MEGA downloader/uploader/streaming suite";
    homepage = "https://github.com/tonikelope/megabasterd";
    changelog = "https://github.com/tonikelope/megabasterd/releases";
    license = pkgs.lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "megabasterd";
  };
}
