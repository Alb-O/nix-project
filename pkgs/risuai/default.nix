{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  electron,
}:

let
  pname = "risuai";
  version = "164.1.2";

  src = fetchurl {
    url = "https://github.com/kwaroran/RisuAI/releases/download/v${version}/RisuAI_${version}_amd64.AppImage";
    sha256 = "0wlcqbk14pa4p6p1pj4pxd87v71dd4kpabnaq8g457vq5qlk61k3";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Install desktop file
    install -Dm444 ${appimageContents}/risuai.desktop $out/share/applications/risuai.desktop
    
    # Install icon
    install -Dm444 ${appimageContents}/risuai.png $out/share/pixmaps/risuai.png
    
    # Fix desktop file paths
    substituteInPlace $out/share/applications/risuai.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}' \
      --replace 'Icon=risuai' 'Icon=${pname}'
  '';

  meta = with lib; {
    description = "A fully featured AI chat client with support for multiple backends";
    homepage = "https://github.com/kwaroran/RisuAI";
    downloadPage = "https://github.com/kwaroran/RisuAI/releases";
    license = licenses.unfree; # License not clearly specified in repo
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}