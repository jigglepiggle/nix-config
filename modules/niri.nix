{ config, pkgs, ... }:

{
  programs.niri.enable = true;

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
