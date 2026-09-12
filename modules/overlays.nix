{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (import ./overlays/pinned.nix)
    (import ./overlays/pvpn.nix)
    (import ./overlays/pokeshell.nix)
  ];
}
