# Basic desktop environment.

{ config, pkgs, ... }:

{
  imports = [
    ./desktop-plasma5.nix
    ./fonts.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };
}
