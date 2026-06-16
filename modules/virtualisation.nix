{ config, pkgs, ... }:

{
    virtualisation.docker = {
      enable           = true;
      enableOnBoot     = false;
      autoPrune.enable = true;
      package          = pkgs.docker_29;

      daemon.settings = {
        log-driver = "json-file";
        log-opts   = { max-size = "10m"; max-file = "3"; };
        };
    };

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package     = pkgs.qemu_kvm;   # KVM-only build, smaller than full QEMU
      runAsRoot   = false;           # run QEMU processes as the session user
      swtpm.enable = true;           # virtual TPM — needed for Win11
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
    dive          # inspect Docker image layers
    ctop          # container resource monitor
    lazydocker    # Docker TUI

    virt-manager        # GUI for libvirt/QEMU VMs
    virt-viewer         # SPICE/VNC console viewer
    virtio-win          # VirtIO drivers ISO for Windows guests
    win-spice           # SPICE guest tools installer for Windows
    swtpm               # software TPM daemon (Win11)

    bridge-utils        # brctl — useful for diagnosing the default NAT bridge
    dnsmasq             # libvirt's default NAT network uses this internally
  ];
}
