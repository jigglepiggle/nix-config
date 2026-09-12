final: prev:

let
  # lunarvim only works against this older neovim build - I really should just config my own neovim :p
  pinned-pkgs = import (builtins.fetchGit {
    name = "my-old-revision";
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "refs/heads/nixos-25.05";
    rev = "cd5f33f23db0a57624a891ca74ea02e87ada2564";
  }) { system = prev.system; };
in
{
  neovim   = pinned-pkgs.neovim;
  lunarvim = pinned-pkgs.lunarvim;
}
