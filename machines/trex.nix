# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../cfg/desktop-gnome3.nix
    ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_4_19;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true; 

  networking.hostName = "trex";
  networking.networkmanager.enable = true;

  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Amsterdam";

  environment.systemPackages = with pkgs; let
  myTuxpaint = tuxpaint.overrideAttrs (oldAttrs: rec {
    postInstall = ''
      mkdir -p $out/share/applications
      cp src/tuxpaint.desktop $out/share/applications/
    '' + oldAttrs.postInstall;
  });
  in [
    extremetuxracer
    gcompris
    krita
    superTux
    superTuxKart
    myTuxpaint
  ];

  nix.buildCores = 4;
  nix.useSandbox = true;

  programs.bash.enableCompletion = true;
  programs.vim.defaultEditor = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  # Services
  services.avahi.enable = true;
  services.openssh.enable = true;
  services.fstrim.enable = true;
  services.xserver.displayManager = {
    hiddenUsers = [ "daniel" "nobody" ];
  };
  security.pam.services = {
    gdm-password.text = ''
      auth sufficient pam_succeed_if.so user ingroup nopasswdlogin
    '';
  };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    checkReversePath = false;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 5353 ];
  };

  # Hardware
  sound.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ vaapiIntel libvdpau-va-gl vaapiVdpau intel-ocl ];
  };
  hardware.pulseaudio.enable = true;

  users.extraUsers = {
    daniel = {
      createHome = true;
      description = "Daniël de Kok";
      home = "/home/daniel";
      #shell = pkgs.zsh;
      extraGroups = [ "wheel" "cdrom" "video" ];
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICjEndjSNA5r4F5fdM9ZL9v1xY5+vGXYGHBUAQGAt5h3"
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxQ5dl7Md+wbS5IzCjTV4MN3fyo+/aeVJFA6ITCq43lWMMmFluooGi078S8huWFZwjuphJota5g/M3Q/U3G7KiCfDZN4HwucPGT8NQFHntRKQ9DdjJfeD+zE3ZTdKYsXe3N5wI5KSIgZIWk6WA4viZLtVVFHrttDirC30g4H9Cx/OdoIzANDtWAOxkYNeTz/lFnawuzbUasVJsCxYJ7AI6BKhaYqR6Fr12ceHEtmXG5nsZ/r6rHqdZHCknvSx1lSbp/cLReWFvlxtipmbvFHAbaVoc1TsRwExvOw26eSOgjqNFKumriVeOTpIlaZXpzGy+tEHeymmN63fF1UmsHUHBw=="
      ];
    };
    doerte = {
      createHome = true;
      description = "Dörte de Kok";
      home = "/home/doerte";
      extraGroups = [ "wheel" "cdrom" "video" ];
      isNormalUser = true;
    };
    liset = {
      createHome = true;
      description = "Liset de Kok";
      home = "/home/liset";
      extraGroups = [ "cdrom" "video" "nopasswdlogin" ];
      isNormalUser = true;
    };
  };

  users.groups = {
    nopasswdlogin.gid = null;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
