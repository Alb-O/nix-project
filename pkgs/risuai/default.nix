{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
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

  # Add necessary runtime dependencies for GTK and graphics
  multiArch = false;
  extraPkgs = pkgs: with pkgs; [
    gtk3
    gtk4
    glib
    gsettings-desktop-schemas
    hicolor-icon-theme
    adwaita-icon-theme
    cairo
    pango
    gdk-pixbuf
    atk
    at-spi2-atk
    at-spi2-core
    dbus
    dbus-glib
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
    wayland-protocols
    mesa
    vulkan-loader
    alsa-lib
    pulseaudio
    fontconfig
    freetype
    harfbuzz
    libGL
    libdrm
    xorg.libXinerama
    xorg.libXScrnSaver
    nspr
    nss
    cups
    expat
    systemd
    libuuid
    libsecret
    libnotify
    xdg-utils
    shared-mime-info
    desktop-file-utils
  ];

  extraInstallCommands = ''
    # Install desktop file
    install -Dm444 ${appimageContents}/RisuAI.desktop $out/share/applications/risuai.desktop
    
    # Install icon
    install -Dm444 ${appimageContents}/RisuAI.png $out/share/pixmaps/risuai.png
    
    # Fix desktop file paths and add environment variables for Wayland/GTK
    substituteInPlace $out/share/applications/risuai.desktop \
      --replace 'Exec=AppRun' 'Exec=env GDK_BACKEND=wayland,x11 WEBKIT_DISABLE_COMPOSITING_MODE=1 ${pname}' \
      --replace 'Icon=RisuAI' 'Icon=${pname}'
      
    # Create wrapper script with proper environment
    makeWrapper $out/bin/${pname} $out/bin/${pname}-wrapped \
      --set GDK_BACKEND "wayland,x11" \
      --set WEBKIT_DISABLE_COMPOSITING_MODE "1" \
      --set GTK_USE_PORTAL "1" \
      --set NIXOS_OZONE_WL "1"
      
    # Replace the original binary with the wrapper
    mv $out/bin/${pname}-wrapped $out/bin/${pname}
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