{ config, pkgs, ... }:

{
  services.printing = {
    enable   = true;
    browsing = true;
    drivers  = with pkgs; [
      gutenprint
      gutenprintBin
      epson-escpr
      foomatic-db
      foomatic-db-ppds
      hplip
    ];
  };

  hardware.sane = {
    enable       = true;
    extraBackends = with pkgs; [ sane-airscan epkowa ];
  };

  # Network printer/scanner discovery is handled by avahi in networking.nix

  environment.systemPackages = with pkgs; [
    system-config-printer
    simple-scan
  ];
}
