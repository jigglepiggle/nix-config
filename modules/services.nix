{ config, pkgs, ... }:

{
  services.dbus = {
    enable   = true;
    packages = with pkgs; [ dconf gcr libsecret ];
  };

  # TLP tuned for the Ryzen 7 4750U (Renoir, 15W TDP)
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC    = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT   = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC  = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # amd_pstate manages frequency; set to 0 to let the driver decide
      CPU_SCALING_MIN_FREQ_ON_AC  = 0;
      CPU_SCALING_MAX_FREQ_ON_AC  = 0;
      CPU_SCALING_MIN_FREQ_ON_BAT = 0;
      CPU_SCALING_MAX_FREQ_ON_BAT = 0;

      CPU_BOOST_ON_AC  = 1;
      CPU_BOOST_ON_BAT = 0;

      # Requires kernel 5.9+ and thinkpad_acpi
      PLATFORM_PROFILE_ON_AC  = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      DISK_APM_LEVEL_ON_AC  = "254";
      DISK_APM_LEVEL_ON_BAT = "128";
      DISK_IOSCHED          = [ "none" "none" ];
      NVME_POWER_ON_BAT     = 1;

      PCIE_ASPM_ON_AC  = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      # Keep AX200 WiFi power save off on AC to avoid latency spikes
      WIFI_PWR_ON_AC  = "off";
      WIFI_PWR_ON_BAT = "on";

      USB_AUTOSUSPEND   = 1;
      USB_EXCLUDE_BTUSB = 1;
      USB_EXCLUDE_PHONE = 1;
      USB_EXCLUDE_WWAN  = 1;

      RUNTIME_PM_ON_AC  = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # Charge thresholds extend battery lifespan; supported via thinkpad_acpi
      START_CHARGE_THRESH_BAT0 = 0;
      STOP_CHARGE_THRESH_BAT0  = 80;

      BAT_PROTECT = 0;
    };
  };

  services.power-profiles-daemon.enable = false;

  services.thinkfan = {
    enable  = true;
    sensors = [{ type = "tpacpi"; query = "/proc/acpi/ibm/thermal"; }];
    fans    = [{ type = "tpacpi"; query = "/proc/acpi/ibm/fan"; }];
    # [ fan_level  low_temp  high_temp ] — conservative for the 4750U
    levels  = [
      [ 0   0   55 ]
      [ 1  50   58 ]
      [ 2  56   63 ]
      [ 3  61   68 ]
      [ 5  66   73 ]
      [ 7  71  127 ]
    ];
  };

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=1month
  '';

  # NTP time sync — systemd-timesyncd in place of chronyd
  services.chrony.enable = false;
  services.timesyncd.enable = true;

  services.cron.enable = true;

  location = {
    provider  = "manual";
    latitude  = 52.50;
    longitude = -1.90;
  };
  services.redshift = {
    enable      = true;
    temperature = { day = 6500; night = 3500; };
  };

  # services.libinput is the sole definition — desktop.nix was cleaned up
  services.libinput = {
    enable                      = true;
    touchpad.tapping            = true;
    touchpad.naturalScrolling   = true;
    touchpad.disableWhileTyping = true;
  };

  services.earlyoom = {
    enable            = true;
    freeMemThreshold  = 5;
    freeSwapThreshold = 5;
  };

  # thermald is Intel-only; has no effect on AMD
  services.thermald.enable = false;
}
