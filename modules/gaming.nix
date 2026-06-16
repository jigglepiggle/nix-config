{ config, pkgs, lib, ... }:

{
  programs.steam = {
    enable                       = true;
    remotePlay.openFirewall      = true;
    dedicatedServer.openFirewall = false;
    gamescopeSession.enable      = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  programs.gamescope.enable = true;
  programs.gamemode.enable  = true;

  environment.systemPackages = with pkgs; [
    wineWowPackages.stagingFull
    winetricks
    prismlauncher
    ryzenadj
    mangohud
    goverlay
    gamemode
    steam-run
    protontricks
  ];

  # hardware.graphics is defined in hardware.nix; Steam/Wine need the 32-bit
  # udev rules for controllers on top of what hardware.nix already sets
  services.udev.packages = with pkgs; [
    game-devices-udev-rules
  ];

  hardware.xpadneo.enable        = false;
  hardware.steam-hardware.enable = true;
}
