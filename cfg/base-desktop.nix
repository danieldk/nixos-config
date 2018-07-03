# Basic desktop environment.

{ config, pkgs, ... }:

{
  imports = [
    ./base-nixos.nix
    ./desktop-plasma5.nix
    ./fonts.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  services.xserver.xkbOptions = "ctrl:nocaps, terminate:ctrl_alt_mksp";
}
