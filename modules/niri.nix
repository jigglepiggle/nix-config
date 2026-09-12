{ config, pkgs, ... }:

{
  programs.niri.enable = true;

  programs.dms-shell = {
    enable = true;
    systemd = {
      enable            = true;
      restartIfChanged  = true;
      target            = "graphical-session.target";
    };
    enableSystemMonitoring = true;
    enableVPN              = true;
    enableDynamicTheming   = true;
    enableAudioWavelength  = true;
    enableCalendarEvents   = true;
  };

  programs.dsearch = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.niri."org.freedesktop.impl.portal.FileChooser" = "gtk";
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    alacritty
    mpvpaper
    waybar
    grim
    slurp
    quickshell

    # moved in from the old desktop.nix
    wayland
    gtk-layer-shell
    xwayland
    xdg-desktop-portal

    qt6.qtwayland
    qt5.qtwayland
    qt6Packages.qt6ct
  ];
}
