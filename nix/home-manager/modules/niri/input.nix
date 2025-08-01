# Input device configuration for Niri
{
  input = {
    keyboard = {
      xkb = {
        # Layout and options can be configured here
        # layout = "us,ru";
        # options = "grp:win_space_toggle,compose:ralt,ctrl:nocaps";
      };
      numlock = true;
    };

    touchpad = {
      tap = true;
      natural-scroll = true;
      # accel-speed = 0.2;
      # accel-profile = "flat";
    };

    mouse = {
      # natural-scroll = false;
      # accel-speed = 0.2;
    };

    trackpoint = {
      # natural-scroll = false;
      # accel-speed = 0.2;
    };

    # focus-follows-mouse.max-scroll-amount = "0%";
  };
}
