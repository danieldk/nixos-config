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

  environment.systemPackages = with pkgs; let
  appindicator = gnomeExtensions.appindicator.overrideAttrs (oldAttrs: rec {
      version = "23";
      src = fetchFromGitHub {
        owner = "Ubuntu";
        repo = "gnome-shell-extension-appindicator";
        rev = "v${version}";
        sha256 = "0xpwdmzf3yxz6y75ngy8cc6il09mp68drzbqsazpprjri73vfy5h";
      };
  });
  in [
    appindicator
  ];
}
