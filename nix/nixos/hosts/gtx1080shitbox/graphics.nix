# Graphics and display configuration
{...}: {
  # NVIDIA graphics driver
  services.xserver.videoDrivers = ["nvidia"];

  # Hardware acceleration and OpenGL
  hardware.graphics = {
    enable = true;
  };

  # NVIDIA driver integration (handles early loading and module setup)
  boot.kernelParams = ["nvidia-drm.modeset=1" "nvidia-drm.fbdev=0"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false; # Use proprietary driver
    nvidiaSettings = true;
  };

  # Extra insurance: force blacklist nouveau (per NixOS Wiki)
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';
}
