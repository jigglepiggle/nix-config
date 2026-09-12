final: prev:

let
  synaTudorSrc = builtins.fetchGit {
    url = "https://github.com/Popax21/synaTudor";
    ref = "refs/heads/relink";
  };

  synatudorDriverExe = prev.fetchurl {
    url    = "https://download.lenovo.com/pccbbs/mobiles/r19fp02w.exe";
    sha256 = "13v9bckwfxypidngr73q3lp3fad6d5wyv38w3dn1ic34jjn6xw09";
  };
in
{
  libfprint-2-tod1-synatudor = prev.stdenv.mkDerivation {
    pname   = "libfprint-2-tod1-synatudor";
    version = "unstable";
    src     = synaTudorSrc;

    sourceRoot = "source";

    nativeBuildInputs = with prev; [
      ninja pkg-config innoextract openssl perl cmake
    ];

    buildInputs = with prev; [
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

    prePatch = ''
      # Fix hardcoded /sbin/tudor in sandbox.c
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
libfprint2_inc = include_directories('${prev.libfprint-tod}/include/libfprint-2', is_system: true)"
      substituteInPlace libfprint-tod/meson.build \
        --replace-warn \
          "dependencies: [libfprint_tod_dep, libusb_dep, gusb_dep, json_glib_dep]," \
          "dependencies: [libfprint_tod_dep, libusb_dep, gusb_dep, json_glib_dep, gio_unix_dep],"
      substituteInPlace libfprint-tod/meson.build \
        --replace-warn \
          "include_directories: [libtudor_inc, tudor_host_inc, tudor_host_launcher_inc]," \
          "include_directories: [libtudor_inc, tudor_host_inc, tudor_host_launcher_inc, libfprint2_inc],"
      substituteInPlace libfprint-tod/meson.build \
        --replace-warn \
          "install_dir: libfprint_tod_dep.get_variable(pkgconfig: 'tod_driversdir')" \
          "install_dir: get_option('libdir') / 'libfprint-2' / 'tod-1'"

      substituteInPlace tudor-host-launcher/meson.build \
        --replace-warn \
          "install_data('tudor-host-launcher.service', install_dir: '/usr/lib/systemd/system/')" \
          "install_data('tudor-host-launcher.service', install_dir: get_option('prefix') / 'lib/systemd/system')"

      substituteInPlace tudor-host-launcher/meson.build \
        --replace-warn \
          "install_dir: dbus_dep.get_variable(pkgconfig: 'datadir') / 'dbus-1/system.d'" \
          "install_dir: get_option('datadir') / 'dbus-1/system.d'"

      substituteInPlace tudor-host-launcher/meson.build \
        --replace-warn \
          "install_dir: dbus_dep.get_variable(pkgconfig: 'system_bus_services_dir')" \
          "install_dir: get_option('datadir') / 'dbus-1/system-services'"

      substituteInPlace libfprint-tod/meson.build \
        --replace-warn \
          "install_dir: udev_dep.get_variable(pkgconfig: 'udevdir')" \
          "install_dir: get_option('prefix') / 'lib/udev/rules.d'"
    '';

    configurePhase = ''
      runHook preConfigure

      ${prev.meson}/bin/meson setup meson-build . \
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
      substituteInPlace $out/lib/systemd/system/tudor-host-launcher.service \
        --replace-warn '/sbin/tudor/' $out/libexec/tudor/
    '';

    passthru.driverPath = "/lib/libfprint-2/tod-1";

    meta = {
      description = "Synaptics 06cb:00be fingerprint reader TOD driver";
      platforms   = prev.lib.platforms.linux;
    };
  };
}
