{ config, lib, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    desktopManager = {
      plasma5.enable = true;
    };
    displayManager = {
      sddm.enable = true;
      sddm.extraConfig = ''
        [Wayland]
        SessionCommand=${lib.getBin pkgs.sddm}/share/sddm/scripts/wayland-session
        SessionDir=/etc/wayland
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    korganizer
  ];
  
  environment.etc."wayland/plasma-wayland.desktop".text = ''
    [Desktop Entry]
    Encoding=UTF-8
    Type=Application
    Exec=${lib.getBin pkgs.plasma-workspace}/bin/startplasmacompositor
    TryExec=${lib.getBin pkgs.plasma-workspace}/bin/startplasmacompositor
    DesktopNames=KDE
    Name=Plasma-wayland
  '';
}
