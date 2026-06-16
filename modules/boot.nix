{ config, pkgs, lib, ... }:

{
  boot.loader.grub = {
    enable      = true;
    device      = "nodev";
    efiSupport  = true;
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # zen kernel adds low-latency desktop patches well-suited to the 4750U;
  # avoid LTS kernels older than 6.6 on Renoir — known suspend/resume regressions
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  boot.kernelParams = [
    "amd_pstate=active"               # hardware P-state driver, best efficiency on 4750U
    "amdgpu.gpu_recovery=1"           # enable GPU reset on hang
    "amdgpu.ppfeaturemask=0xffffffff" # expose all power-play tuning knobs
    "quiet"
    "splash"
  ];

  boot.plymouth.enable = true;

  boot.tmp.useTmpfs  = true;
  boot.tmp.tmpfsSize = "20%";
}
