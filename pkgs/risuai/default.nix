{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  wrapGAppsHook,
  gtk3,
  glib,
  cairo,
  pango,
  gdk-pixbuf,
  atk,
  at-spi2-atk,
  dbus,
  libX11,
  libXcursor,
  libXrandr,
  libXi,
  libXext,
  libXfixes,
  libXrender,
  libXcomposite,
  libXdamage,
  libxkbcommon,
  wayland,
  mesa,
  vulkan-loader,
  alsa-lib,
  pulseaudio,
  fontconfig,
  freetype,
  libdrm,
  nss,
  nspr,
  cups,
  expat,
  systemd,
  libuuid,
  at-spi2-core,
  libsecret,
  libnotify,
  xdg-utils,
  autoPatchelfHook,
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
    gtk3
    glib
    cairo
    pango
    gdk-pixbuf
    atk
    at-spi2-atk
    at-spi2-core
    dbus
    libX11
    libXcursor
    libXrandr
    libXi
    libXext
    libXfixes
    libXrender
    libXcomposite
    libXdamage
    libxkbcommon
    wayland
    mesa
    vulkan-loader
    alsa-lib
    pulseaudio
    fontconfig
    freetype
    libdrm
    nss
    nspr
    cups
    expat
    systemd
    libuuid
    libsecret
    libnotify
    xdg-utils
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