{ config, lib, pkgs, ... }:

{
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
  ];
}
