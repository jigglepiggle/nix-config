{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox
    discord

    libreoffice-fresh
    hunspell
    hunspellDicts.en_GB-ise
    hunspellDicts.en_US
    hunspellDicts.de_DE
    hunspellDicts.es_ES
    hunspellDicts.it_IT
    hunspellDicts.pl_PL
    mythes

    texliveFull
    texstudio

    flatpak

    p7zip
    unzip
    unrar
    zip
    cabextract
    libarchive

    e2fsprogs
    btrfs-progs
    xfsprogs
    f2fs-tools
    dosfstools
    ntfs3g
    parted
    gptfdisk
    hdparm
    smartmontools
    ncdu
    duf

    btop
    htop
    lm_sensors
    acpi
    dmidecode
    pciutils
    usbutils
    lsof
    strace
    ethtool
    iw

    libwacom
    xf86_input_wacom

    libimobiledevice  # Apple iOS devices
    ifuse             # mount iPhone/iPad
    libmtp
    jmtpfs

    fwupd
    bolt

    cmatrix
    sl
    fastfetch
    onefetch
    bluetui

    rclone
    fontconfig

    tmux
    fzf
    ripgrep
    eza
    starship
    zoxide
    bat

    thunar
  ];

  services.flatpak.enable        = true;
  services.fwupd.enable          = true;
  services.hardware.bolt.enable  = true;

  services.smartd = {
    enable     = true;
    autodetect = true;
  };

  services.udisks2.enable = true;
  services.gvfs.enable    = true;
  services.gvfs.package   = pkgs.gvfs;

  xdg.mime.enable      = true;
  xdg.autostart.enable = true;
}
