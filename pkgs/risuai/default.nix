{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  wrapGAppsHook,
  autoPatchelfHook,
  # Runtime dependencies
  gtk3,
  glib,
  webkitgtk_4_1,
  libsoup_3,
  cairo,
  pango,
  gdk-pixbuf,
  nss,
  libsecret,
  libnotify,
}:

let
  pname = "risuai";
  version = "164.1.2";

  src = fetchurl {
    url = "https://github.com/kwaroran/RisuAI/releases/download/v${version}/RisuAI_${version}_amd64.deb";
    sha256 = "03k05prpj6hblg92hjdmgl4lz5hpa4q89jj4zz4r8bz0wr346f5l";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ 
    dpkg 
    autoPatchelfHook 
    wrapGAppsHook 
  ];

  buildInputs = [
    # Core GTK and GLib
    gtk3
    glib
    
    # WebKit dependencies (essential for Tauri apps)
    webkitgtk_4_1
    libsoup_3
    
    # Basic graphics and rendering
    cairo
    pango
    gdk-pixbuf
    
    # Security and crypto
    nss
    
    # System integration
    libsecret
    libnotify
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall
    
    # Install the application
    mkdir -p $out/bin $out/share
    cp -r usr/share/* $out/share/
    cp -r usr/bin/* $out/bin/ || true
    
    # Find and install the actual binary
    find . -name "risuai" -o -name "RisuAI" -type f -executable | head -1 | xargs -I {} cp {} $out/bin/${pname}
    
    # Fix desktop file if it exists
    if [ -f $out/share/applications/risuai.desktop ]; then
      substituteInPlace $out/share/applications/risuai.desktop \
        --replace-fail 'Exec=RisuAI' 'Exec=${pname}' \
        --replace-fail 'Exec=risuai' 'Exec=${pname}' \
        --replace-fail 'Icon=RisuAI' 'Icon=risuai' || true
    fi
    
    runHook postInstall
  '';

  # Let wrapGAppsHook handle the GTK setup
  dontWrapGApps = false;

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