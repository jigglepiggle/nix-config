{ config, pkgs, ... }:

{
  users.users.lain = {
    isNormalUser = true;
    description  = "lain";
    uid          = 1000;
    extraGroups  = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      "render"          # DRM render nodes for Vulkan and OpenCL
      "kvm"
      "libvirtd"
      "docker"
      "plugdev"         # USB HID devices
      "dialout"         # serial ports
      "scanner"
      "lp"
      "storage"
      "seat"
    ];
    shell = pkgs.zsh;
  };

  nix.settings.trusted-users = [ "root" "lain" ];

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "colorize"
        "colored-man-pages"
      ];
    };
  };

  environment.shells = with pkgs; [ zsh ];
}
