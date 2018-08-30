{ config, lib, pkgs, ... }:

{
  imports = [
    ./base-desktop.nix
  ];

  services.xserver = {
    enable = true;
    desktopManager = {
      plasma5.enable = true;
    };
    displayManager = {
      sddm.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    gwenview
    korganizer
    okular
  ];
}
