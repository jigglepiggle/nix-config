{ config, pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      nerd-fonts.noto
      nerd-fonts.symbols-only

      source-code-pro
      source-sans-pro

      liberation_ttf

      dejavu_fonts

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji

      freefont_ttf
      unifont

      amiri               # Classical Arabic Naskh typeface
      culmus              # Hebrew fonts
      scheherazade-new

      twemoji-color-font

      ubuntu-classic
      open-sans
    ];

    fontconfig = {
      enable         = true;
      antialias      = true;
      hinting.enable = true;
      hinting.style  = "slight";
      subpixel.rgba  = "rgb";

      defaultFonts = {
        serif     = [ "Source Serif 4"  "Noto Serif"              "DejaVu Serif"     ];
        sansSerif = [ "Source Sans 3"   "Noto Sans"               "DejaVu Sans"      ];
        monospace = [ "Source Code Pro" "JetBrainsMono Nerd Font"  "DejaVu Sans Mono" ];
        emoji     = [ "Noto Color Emoji" ];
      };
    };
  };
}
