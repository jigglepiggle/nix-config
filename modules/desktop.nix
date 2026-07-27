{ config, pkgs, ... }:

let
  dwm-custom = pkgs.dwm.overrideAttrs (old: {
    src = /home/lain/Development/applications/dwm;
    postPatch = ''
      sed -i "s|PREFIX = /usr/local|PREFIX = $out|" config.mk
    '';
    buildInputs = (old.buildInputs or []) ++ (with pkgs; [
      xorg.libX11
      xorg.libXft
      xorg.libXinerama
      harfbuzz
    ]);
  });

  dwmXinitrc = pkgs.writeShellScript "xinitrc-dwm" ''
    [ -f ~/.Xresources ] && xrdb -merge ~/.Xresources
    setxkbmap gb
    picom --daemon &
    sh ~/.fehbg &
    slstatus &
    dunst &
    nm-applet &
    #xset dpms 300 600 900
    xset s off -dpms
    xss-lock --transfer-sleep-lock \
      -n "$(dirname $(which xsecurelock))/../libexec/xsecurelock/dimmer" \
      -l -- env XSECURELOCK_PAM_SERVICE=xsecurelock xsecurelock &
    dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP=DWM
    exec ${dwm-custom}/bin/dwm
  '';

in
{
  services.xserver = {
    enable = true;
    xkb = {
      layout  = "gb";
      variant = "";
      options = "caps:escape";
    };
    videoDrivers = [ "amdgpu" ];
  };

  # No display manager — log in on a TTY and run startx
  services.xserver.displayManager.startx.enable = true;

  # Xorg needs setuid to open /dev/tty0 when launched via startx from a TTY.
  # Without this, X fails with "Cannot open /dev/tty0 (Permission denied)".
  security.wrappers.Xorg = {
    source  = "${pkgs.xorg.xorgserver}/bin/Xorg";
    owner   = "root";
    group   = "root";
    setuid  = true;
  };
  environment.etc."X11/xinit/xinitrc".source = dwmXinitrc;

  services.colord.enable          = true;
  services.accounts-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    dwm-custom
    dmenu
    st
    slstatus
    xorg.xsetroot

    picom
    dunst
    libnotify
    flameshot
    scrot
    feh
    networkmanager_dmenu
    rofi

    xclip
    xdotool

    xsecurelock
    xss-lock
    xlockmore
    xautolock

    xorg.xrandr
    xorg.xrdb
    xorg.xev
    xorg.xprop
    xorg.xset
    xorg.xsetroot
    xorg.xinput
    xorg.xmodmap
    xorg.xdpyinfo
    xorg.xkill
    xorg.xauth
    xorg.xclock
    xorg.xeyes
    xorg.xload
    xorg.xcalc
    xorg.xwininfo
    transset
    xbacklight

    wayland
    gtk-layer-shell
    xwayland
    xdg-desktop-portal
    xdg-desktop-portal-gtk

    adwaita-icon-theme
    hicolor-icon-theme
    libadwaita
    dconf
    gsettings-desktop-schemas
    gtk3
    gtk4
    lxappearance

    qt6.qtwayland
    qt5.qtwayland
    qt6Packages.qt6ct

    networkmanagerapplet
    pasystray
    blueman
  ];

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "DWM";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common.default = "gtk";
  };

  # services.libinput and services.acpid are defined in hardware.nix and
  # services.nix respectively — only one definition per attribute is allowed

  services.upower.enable = true;

  security.polkit.enable = true;

  services.gnome.at-spi2-core.enable = true;

  services.tumbler.enable = true;

  programs.dconf.enable = true;
}
