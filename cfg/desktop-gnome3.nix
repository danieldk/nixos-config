{ config, lib, pkgs, ... }:

{
  imports = [
    ./base-desktop.nix
  ];

  services.xserver = {
    enable = true;
    desktopManager = {
      gnome3.enable = true;
    };
    displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
    };
  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
  ];
}
