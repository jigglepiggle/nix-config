{ config, pkgs, lib, ... }:

let
  synaTudorSrc = builtins.fetchGit {
    url = "https://github.com/Popax21/synaTudor";
    ref = "refs/heads/relink";
  };

  synatudorDriverExe = pkgs.fetchurl {
    url    = "https://download.lenovo.com/pccbbs/mobiles/r19fp02w.exe";
    sha256 = "13v9bckwfxypidngr73q3lp3fad6d5wyv38w3dn1ic34jjn6xw09";
  };

  libfprint-2-tod1-synatudor = pkgs.stdenv.mkDerivation {
    pname   = "libfprint-2-tod1-synatudor";
    version = "unstable";
    src     = synaTudorSrc;

    # meson.build is at the root of the relink branch
    sourceRoot = "source";

    nativeBuildInputs = with pkgs; [
      ninja pkg-config innoextract openssl perl cmake
    ];

    buildInputs = with pkgs; [
      libusb1 pixman nss systemd libgudev glib libcap libseccomp dbus json-glib gusb libfprint-tod
    ];
    postPatch = ''
      # Substitute @out@ in sandbox.c with the real nix store output path
      substituteAll tudor-host/src/sandbox.c tudor-host/src/sandbox.c

      # Replace the download script with one that uses our pre-fetched exe
      cat > libtudor/download_driver.sh << 'DLSCRIPT'
#!/bin/bash -e
HASH_FILE="$1"
TMP_DIR="$2"
OUT_DIR="$3"
DLLS="''${@:4}"
mkdir -p "$TMP_DIR"
INSTALLER="$TMP_DIR/installer.exe"
cp @EXE@ "$INSTALLER"
WINDRV="$TMP_DIR/windrv"
mkdir -p "$WINDRV"
innoextract -d "$WINDRV" "$INSTALLER"
mkdir -p "$OUT_DIR"
for dll in $DLLS
do
    cp $(find "$WINDRV" -name "$dll") "$OUT_DIR/$dll"
done
DLSCRIPT
      substituteInPlace libtudor/download_driver.sh --replace @EXE@ ${synatudorDriverExe}
      chmod +x libtudor/download_driver.sh
    '';

    # Patch meson.build files before build
    prePatch = ''
      # Fix hardcoded /sbin/tudor in sandbox.c
      # substituteAll will replace @out@ with the nix store output path
      sed -i 's|"/sbin/tudor"|"@out@/libexec/tudor"|g' tudor-host/src/sandbox.c

      # Fix hardcoded /sbin/tudor install path
      substituteInPlace meson.build \
        --replace-warn \
          "INSTALL_DIR = '/sbin/tudor'" \
          "INSTALL_DIR = get_option('libexecdir') / 'tudor'"

      # Add gio-unix-2.0 dep and libfprint-2 include to libfprint-tod subdir
      substituteInPlace libfprint-tod/meson.build \
        --replace-warn \
          "libfprint_tod_dep = dependency('libfprint-2-tod-1')" \
          "libfprint_tod_dep = dependency('libfprint-2-tod-1')
gio_unix_dep = dependency('gio-unix-2.0')
libfprint2_inc = include_directories('${pkgs.libfprint-tod}/include/libfprint-2', is_system: true)"
      substituteInPlace libfprint-tod/meson.build \
        --replace-warn \
          "dependencies: [libfprint_tod_dep, libusb_dep, gusb_dep, json_glib_dep]," \
          "dependencies: [libfprint_tod_dep, libusb_dep, gusb_dep, json_glib_dep, gio_unix_dep],"
      substituteInPlace libfprint-tod/meson.build \
        --replace-warn \
          "include_directories: [libtudor_inc, tudor_host_inc, tudor_host_launcher_inc]," \
          "include_directories: [libtudor_inc, tudor_host_inc, tudor_host_launcher_inc, libfprint2_inc],"
      # Fix install_dir: don't install into the read-only libfprint-tod store path
      substituteInPlace libfprint-tod/meson.build \
        --replace-warn \
          "install_dir: libfprint_tod_dep.get_variable(pkgconfig: 'tod_driversdir')" \
          "install_dir: get_option('libdir') / 'libfprint-2' / 'tod-1'"

      # Fix hardcoded /usr/lib/systemd/system/ path
      substituteInPlace tudor-host-launcher/meson.build \
        --replace-warn \
          "install_data('tudor-host-launcher.service', install_dir: '/usr/lib/systemd/system/')" \
          "install_data('tudor-host-launcher.service', install_dir: get_option('prefix') / 'lib/systemd/system')"

      # Fix dbus system.d path (would go into read-only dbus store path)
      substituteInPlace tudor-host-launcher/meson.build \
        --replace-warn \
          "install_dir: dbus_dep.get_variable(pkgconfig: 'datadir') / 'dbus-1/system.d'" \
          "install_dir: get_option('datadir') / 'dbus-1/system.d'"

      # Fix dbus system-services path (/etc/dbus-1/system-services -> our output)
      substituteInPlace tudor-host-launcher/meson.build \
        --replace-warn \
          "install_dir: dbus_dep.get_variable(pkgconfig: 'system_bus_services_dir')" \
          "install_dir: get_option('datadir') / 'dbus-1/system-services'"

      # Fix udev rules install path (would go into read-only systemd store path)
      substituteInPlace libfprint-tod/meson.build \
        --replace-warn \
          "install_dir: udev_dep.get_variable(pkgconfig: 'udevdir')" \
          "install_dir: get_option('prefix') / 'lib/udev/rules.d'"
    '';

    configurePhase = ''
      runHook preConfigure

      ${pkgs.meson}/bin/meson setup meson-build . \
        --prefix=$out \
        --libdir=$out/lib \
        --libexecdir=$out/libexec \
        --bindir=$out/bin \
        -Dwrap_mode=nodownload \
        --buildtype=plain

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild
      ninja -C meson-build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      ninja -C meson-build install
      runHook postInstall
    '';

    postInstall = ''
      # Fix hardcoded /sbin/tudor in the installed systemd service file
      substituteInPlace $out/lib/systemd/system/tudor-host-launcher.service \
        --replace-warn '/sbin/tudor/' $out/libexec/tudor/
    '';

    passthru.driverPath = "/lib/libfprint-2/tod-1";

    meta = {
      description = "Synaptics 06cb:00be fingerprint reader TOD driver";
      platforms   = lib.platforms.linux;
    };
  };

in
{
  security.sudo = {
    enable             = true;
    wheelNeedsPassword = true;
    extraRules = [
      {
        users = [ "ALL" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/wg-quick up *";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/wg-quick down *";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  security.pam.services = {
    login.enableGnomeKeyring = true;
  };

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

  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = libfprint-2-tod1-synatudor;
    };
  };

  # Register tudor-host-launcher with D-Bus so fprintd can activate it
  services.dbus.packages = [ libfprint-2-tod1-synatudor ];

  # Register tudor-host-launcher systemd service
  systemd.packages = [ libfprint-2-tod1-synatudor ];

  security.pam.services.login.fprintAuth = true;
  security.pam.services.sudo.fprintAuth  = true;

  security.pam.services.xsecurelock = {
    text = ''
      auth sufficient pam_fprintd.so
      auth include login
    '';
  };
}
