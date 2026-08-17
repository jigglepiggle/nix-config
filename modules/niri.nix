{ config, pkgs, ... }:

{
  programs.niri.enable = true;
  
  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true;             # Systemd service for auto-start
      restartIfChanged = true;   # Auto-restart dms.service when dms-shell changes
      target = "graphical-session.target";
    };
    
    # Core features
    enableSystemMonitoring = true;     # System monitoring widgets (dgop)
    enableVPN = true;                  # VPN management widget
    enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
    enableAudioWavelength = true;      # Audio visualizer (cava)
    enableCalendarEvents = true;       # Calendar integration (khal)
  };

  programs.dsearch = {
    enable = true;

    # Systemd service configuration
    systemd = {
      enable = true;               # Enable systemd user service
      target = "graphical-session.target";   # Start with user session
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
    fuzzel 
    awww
    waybar
    grim
    slurp
    quickshell
  ];
}
