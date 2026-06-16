{ ... }:
{
  services.libinput = {
    enable = true;
    touchpad = {
      accelSpeed = "0.0";
      accelProfile = "flat";        # consistent speed, no curve
      naturalScrolling = true;
      tapping = true;
      tappingDragLock = true;
      disableWhileTyping = true;
    };
  };

  services.xserver.inputClassSections = [
    ''
      Identifier "touchpad speed"
      MatchIsTouchpad "on"
      Driver "libinput"
      Option "TransformationMatrix" "2.0 0 0 0 2.0 0 0 0 1"
    ''
  ];
}
