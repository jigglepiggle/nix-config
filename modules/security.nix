{ config, pkgs, lib, ... }:

{
  security.sudo = {
    enable             = true;
    wheelNeedsPassword = true;
    extraRules = [
      {
        users = [ "ALL" ];
        commands = [
          { command = "/run/current-system/sw/bin/wg-quick up *";   options = [ "NOPASSWD" ]; }
          { command = "/run/current-system/sw/bin/wg-quick down *"; options = [ "NOPASSWD" ]; }
        ];
      }
    ];
  };

  security.pam.services.login.enableGnomeKeyring = true;

  programs.gnupg.agent = {
    enable           = true;
    enableSSHSupport = true;
    pinentryPackage  = pkgs.pinentry-gtk2;
  };

  services.openssh = {
    enable   = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin        = "no";
    };
  };

  security.apparmor.enable = false;
  security.audit.enable    = false;

  security.tpm2 = {
    enable                 = true;
    pkcs11.enable          = true;
    tctiEnvironment.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.kwallet
    kdePackages.kwallet-pam
    kdePackages.ksshaskpass
    trousers
  ];

  # pkgs.libfprint-2-tod1-synatudor comes from the overlay
  #services.fprintd = {
  #  enable = false;
  #  tod = {
  #    enable = true;
  #    driver = pkgs.libfprint-2-tod1-synatudor;
  #  };
  #};

  #services.dbus.packages = [ pkgs.libfprint-2-tod1-synatudor ];
  #systemd.packages       = [ pkgs.libfprint-2-tod1-synatudor ];

  #security.pam.services.login.fprintAuth = true;
  #security.pam.services.sudo.fprintAuth  = true;

  security.pam.services.xsecurelock = {
    text = ''
      #auth sufficient pam_fprintd.so
      auth include login
    '';
  };
}
