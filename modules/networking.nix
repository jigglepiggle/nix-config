{ config, pkgs, ... }:

{
  networking = {
    hostName = "navi";
    networkmanager.enable = true;
    firewall = {
      enable          = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];

  hardware.bluetooth = {
    enable      = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };
  #services.blueman.enable = true;

  services.openvpn.servers  = { };
  networking.wireguard.enable = false;

  services.avahi = {
    enable      = true;
    nssmdns4    = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    iproute2        # ip, ss, tc
    ethtool
    iw              # nl80211 wifi config
    nmap
    netcat-gnu
    traceroute
    wget
    curl
    rsync
    gobuster
    thc-hydra
    wireguard-tools
    wol             # Wake-on-LAN
  ];
}
