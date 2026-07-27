{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gcc
    binutils
    gnumake
    autoconf
    automake
    libtool
    cmake
    ninja
    meson
    pkg-config
    pkgconf
    bison
    flex
    m4
    patch
    patchelf

    rustup
    nodejs_24

    python314
    python3Packages.pip
    python3Packages.pygments
    python3Packages.jinja2
    python3Packages.packaging

    jdk8
    jdk11
    jdk17
    jdk21

    llvmPackages_21.llvm
    llvmPackages_21.clang
    llvmPackages_21.clang-tools
    llvmPackages_21.lld
    llvmPackages_21.mlir
    llvmPackages_21.compiler-rt

    gdb
    strace
    lsof
    pahole
    valgrind

    git
    onefetch

    nano
    vscode

    kitty
    tmux
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf
    ripgrep
    eza
    bat
    fd
    starship
    ncdu
    btop
    fastfetch
    cloc
    jq
    yq

    nasm
    glslang
    shaderc
    spirv-llvm-translator
    opencl-headers
    vulkan-headers
    vulkan-loader
    vulkan-tools
    ocl-icd

    protobuf

    devenv

    sqlite
    postgresql

    gobuster
    thc-hydra
    nmap
    flashrom
    openssl

    gnupg
    pinentry-gtk2
    file
    tree
    which
    bc
    ed
    diffutils
    findutils
    gawk
    cpio
    unzip
    unrar
    p7zip
    cabextract
    zip
    xz
    zstd
    bzip2
    lzo
    snappy
    rhash
    dialog
    less
    man-pages
    manix
  ];

  virtualisation.docker = {
    enable           = true;
    enableOnBoot     = false;
    autoPrune.enable = true;
  };

  programs.java = {
    enable  = true;
    package = pkgs.jdk21;
  };

  programs.direnv = {
    enable            = true;
    nix-direnv.enable = true;
  };
}
