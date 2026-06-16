{ config, pkgs, lib, ... }:

let
  pinned-pkgs = import (builtins.fetchGit {
    name = "my-old-revision";
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "refs/heads/nixos-25.05";
    rev = "cd5f33f23db0a57624a891ca74ea02e87ada2564";
  }) { system = pkgs.system; };
in {
  environment.systemPackages = [
    pinned-pkgs.neovim
    pinned-pkgs.lunarvim
  ];
}
