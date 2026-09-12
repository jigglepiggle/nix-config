{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.pvpn ];

  users.groups.pvpn = { };
  users.users.lain.extraGroups = [ "pvpn" ];

  systemd.services.pvpnd = {
    description = "pVPN Daemon - Proton VPN Connection Manager";
    after        = [ "network-online.target" ];
    wants        = [ "network-online.target" ];
    wantedBy     = [ "multi-user.target" ];

    environment.HOME = "/var/lib/pvpn";

    serviceConfig = {
      Type    = "simple";
      ExecStart = "${pkgs.pvpn}/bin/pvpnd";
      Restart   = "on-failure";
      RestartSec = 5;

      RuntimeDirectory   = "pvpn";
      StateDirectory     = "pvpn";
      StateDirectoryMode = "0700";

      ReadWritePaths = [ "/run/pvpn" "/etc/resolv.conf" "/etc/pvpn" "/var/lib/pvpn" ];

      ProtectHome      = true;
      PrivateTmp       = true;
      LockPersonality  = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
    };
  };
}
