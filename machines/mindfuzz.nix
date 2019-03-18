# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_4_19;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true; 
  boot.supportedFilesystems = [ "zfs" ];

  boot.kernelParams = [
    # Limit maximum ARC size to 4GB
    "zfs.zfs_arc_max=4294967296"
  ];

  networking.hostName = "mindfuzz";
  #networking.networkmanager.enable = true;

  i18n = {
    # Bigger console font for 4k screen.
    consoleFont = "latarcyrheb-sun32";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
  ];

  nix.buildCores = 2;
  nix.useSandbox = true;

  programs.bash.enableCompletion = true;
  programs.vim.defaultEditor = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  # Services
  services.avahi.enable = true;

  #services.fwupd.enable = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  #services.plex = {
  #  enable = true;
  #  openFirewall = true;
  #};
  
  services.resilio = {
    enable = true;
    enableWebUI = true;
    deviceName = "mindfuzz";
  };

  services.samba = {
    enable = true;
    shares = {
      homes = {
        comment = "Home Directories";
        browseable = "no";
        writable = "yes";
      };
      media = {
        path = "/srv/media";
        "valid users" = "daniel doerte mediaclient";
        browsable = "yes";
        writable = "no";
        "write list" = "daniel doerte";
        "inherit acls" = "yes";
      };
    };
  };
  services.zfs.autoScrub.enable = true;

  networking.firewall = {
    enable = true;
    checkReversePath = false;
    allowedTCPPorts = [ 22 139 445 9000 ];
    allowedUDPPorts = [ 137 138 ];
  };

  networking.hostId = "8bfc957f";

  # Hardware
  hardware.cpu.intel.updateMicrocode = true;

  users.extraUsers = {
    daniel = {
      createHome = true;
      home = "/home/daniel";
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICjEndjSNA5r4F5fdM9ZL9v1xY5+vGXYGHBUAQGAt5h3"
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxQ5dl7Md+wbS5IzCjTV4MN3fyo+/aeVJFA6ITCq43lWMMmFluooGi078S8huWFZwjuphJota5g/M3Q/U3G7KiCfDZN4HwucPGT8NQFHntRKQ9DdjJfeD+zE3ZTdKYsXe3N5wI5KSIgZIWk6WA4viZLtVVFHrttDirC30g4H9Cx/OdoIzANDtWAOxkYNeTz/lFnawuzbUasVJsCxYJ7AI6BKhaYqR6Fr12ceHEtmXG5nsZ/r6rHqdZHCknvSx1lSbp/cLReWFvlxtipmbvFHAbaVoc1TsRwExvOw26eSOgjqNFKumriVeOTpIlaZXpzGy+tEHeymmN63fF1UmsHUHBw=="
      ];
    };

    doerte = {
      createHome = true;
      home = "/home/doerte";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA8Xz5MAKVBVGeyeybDaTXz+kBlzPiLrX6K1DKeVjchUu8nnahTIFPjv5vlLZMc3SUKiNNdTCuOJD4e6Nv2xFP+CO+7vV4AEJbRPyBRVx+3VPH8anGtg6Eyrc8EeqEr8G4tKf5cmVYNzzEnEo01Pc7iGWCA19Qe+Dy2k7RSyLNhzPLUCPD3rKTn0asK4bfw9kfmAcbYe/gaV22ZZYBrbK6A0W2cxT1ZMJz7ollDHehP+WKAIMHioMwFAlkqUAqqeb3D2okBcSkYg8pduUy6lsu251iEvdn8L3oRD2/F/oKxgUyYm8REEJWT7Nh23aTjqBbhIieIMaoFRrZoYikrgZ5Fw== me@doerte.eu"
      ];
    };

    mediaclient = {};
  };

  system.stateVersion = "18.09";
}
