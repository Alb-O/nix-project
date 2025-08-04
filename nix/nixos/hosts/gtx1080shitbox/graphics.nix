# Graphics and display configuration
{...}: {
  # NVIDIA graphics driver
  services.xserver.videoDrivers = ["nvidia"];

  # Hardware acceleration and OpenGL
  hardware.graphics = {
    enable = true;
  };
}
