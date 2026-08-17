{ config, pkgs, ... }:

{
  services.pipewire = {
    enable             = true;
    alsa.enable        = true;
    alsa.support32Bit  = true;  # required for Wine and Steam
    pulse.enable       = true;  # PulseAudio compatibility shim
    jack.enable        = true;  # JACK compatibility shim
    wireplumber.enable = true;
  };

  services.pulseaudio.enable = false;

  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    pavucontrol   # volume control GUI (works via PipeWire PulseAudio shim)
    pulseaudio    # provides pactl and pacmd; daemon itself is disabled
    alsa-utils    # aplay, amixer, arecord
    playerctl     # MPRIS media key controller
    cava          # terminal audio visualiser
    lame          # MP3 encoder
#    faac
    faad2
    flac
    libvorbis
    speexdsp
    sox
    soundtouch
    sndio
    qjackctl
  ];
}
