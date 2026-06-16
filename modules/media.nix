{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mpv
    vlc
    ffmpeg_7
    ffmpegthumbnailer

    spotify

    obs-studio
    obs-studio-plugins.obs-pipewire-audio-capture

    mlt
    movit

    feh
    imagemagick
    gimp
    inkscape

    evince
    zathura
    djvulibre

    mediainfo
    chromaprint

    x264
    x265
    libvpx
    dav1d
    rav1e
    svt-av1
    openh264
    libheif
    libjxl
    libavif
    libbluray
    libdvdcss
    libdvdread
    libdvdnav
    dvdauthor

    libass

    remmina
    freerdp

    jellyfin-media-player

    fontforge
    calibre
    flameshot
    scrot

    yt-dlp
    playerctl
  ];

  # hardware.graphics and environment.sessionVariables (LIBVA_DRIVER_NAME etc.)
  # are defined in hardware.nix to avoid attrset redefinition errors
}
