# Basic NixOS Unix environment.

{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> {};
in {
  environment.systemPackages = [ unstable.home-manager ];
}
