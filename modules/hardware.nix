{ config, pkgs, lib, ... }:

# ThinkPad L14 Gen 1 AMD — Ryzen 7 4750U (Renoir)
# No dedicated nixos-hardware profile exists for this model; this module
# manually applies the same tweaks as the P14s AMD Gen 1 (same Renoir SoC)
# plus L14-specific quirks.
#
# Hardware:
#   CPU  : AMD Ryzen 7 4750U (8c/16t, Renoir, 15W TDP)
#   GPU  : AMD Radeon RX Vega 7 (Renoir iGPU, amdgpu driver)
#   RAM  : Up to 48 GB DDR4-3200 (8 GB soldered + 1x SO-DIMM slot)
#   NVMe : M.2 2242 or 2280 PCIe Gen3x4
#   WiFi : Intel Wi-Fi 6 AX200 (iwlwifi)
#   LAN  : Realtek RTL8111 GbE
#   Audio: AMD ACP/Renoir (SOF firmware) — headphone jack + internal mic
#   Ports: 2x USB-A 3.2 Gen1, 1x USB-C (DP+PD, no Thunderbolt), HDMI 2.0, SD
#   Display: 14" FHD IPS 1920x1080

{
  hardware.cpu.amd.updateMicrocode = true;

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware             = true;
  # SOF firmware for the Renoir ACP audio block is included in linux-firmware

  # Renoir iGPU needs amdgpu loaded early for proper kernel modesetting
  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.kernelModules = [
    "kvm-amd"
    "v4l2loopback"
    "thinkpad_acpi"      # fan control, temperatures, hotkeys, LEDs
    "ucsi_acpi"          # USB-C PD negotiation (the L14 has no Thunderbolt)
    "cros_usbpd_charger"
  ];

  boot.extraModprobeConfig = ''
    # AX200 — prevents the common disconnection bug on this card
    options iwlwifi power_save=0
    options iwlmvm power_scheme=1
    # Prevents NVMe deepest sleep state, which causes latency spikes on L14 drives
    options nvme_core default_ps_max_latency_us=5500
  '';

  # The L14 Gen 1 AMD supports s2idle (S0ix) but not classic S3;
  # without this, resume from suspend hangs
  boot.kernelParams = [ "mem_sleep_default=deep" ];

  # Owns all hardware.graphics config — gaming.nix and media.nix extend it
  # via extraPackages which NixOS merges as a list, but the attrset itself
  # must only be opened once; all keys live here
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;   # required for Wine and Steam 32-bit
    extraPackages = with pkgs; [
      mesa
      rocmPackages.clr
      libva-utils
      libva-vdpau-driver
      libva
      libvdpau
    ];
    extraPackages32 = with pkgs; [
      pkgsi686Linux.mesa
    ];
  };

  # All session variables in one place to avoid the attrset redefinition error
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER      = "radeonsi";
    AMD_VULKAN_ICD    = "RADV";
  };

  powerManagement.enable = true;

  services.acpid.enable = true;

  # TrackPoint middle-button scroll emulation
  services.xserver.inputClassSections = [
    ''
      Identifier "ThinkPad TrackPoint"
      MatchProduct "TrackPoint"
      MatchIsPointer "yes"
      Option "EmulateWheel"        "true"
      Option "EmulateWheelButton"  "2"
      Option "EmulateWheelTimeout" "200"
      Option "XAxisMapping"        "6 7"
      Option "YAxisMapping"        "4 5"
    ''
  ];

  services.logind.settings.Login = {
    HandleLidSwitch              = "suspend";
    HandleLidSwitchDocked        = "ignore";
    HandleLidSwitchExternalPower = "suspend";
    HandlePowerKey               = "suspend";
    HandleSuspendKey             = "suspend";
    IdleAction                   = "ignore";
  };

  # Compressed swap avoids SSD wear and is fast on the 4750U
  zramSwap = {
    enable        = true;
    algorithm     = "zstd";
    memoryPercent = 50;
  };

  # SD card reader (RTS5227S) is handled automatically by rtsx_pci

  environment.systemPackages = with pkgs; [
    ryzenadj      # runtime TDP / power limit tuning
    lm_sensors    # fan and temperature readings via thinkpad_acpi
    powertop      # per-process power consumption
    acpi          # battery and thermal info
    dmidecode     # BIOS and board identification
    nvme-cli      # NVMe drive health and firmware
    smartmontools # SMART disk health
    inxi          # full hardware summary (inxi -Fxz)
    brightnessctl
  ];
}
