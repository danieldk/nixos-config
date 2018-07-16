# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> {};
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../cfg/base-desktop.nix
    ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];
  boot.kernelParams = [
    "radeon.si_support=0"
    "amdgpu.si_support=1"
  ];
  boot.kernelPackages = unstable.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true; 
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.enableUnstable = true;

  networking.hostName = "mindbender";
  networking.networkmanager.enable = true;

  i18n = {
  #   consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixops
  ];

  nix.buildCores = 8;
  nix.useSandbox = true;

  programs.bash.enableCompletion = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.vim.defaultEditor = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  # Services

  services.openssh.enable = true;
  services.pcscd.enable = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];
  services.zfs.autoScrub.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Hardware
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.u2f.enable = true;

  users.extraUsers.daniel = {
    createHome = true;
    home = "/home/daniel";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    isNormalUser = true;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?

}
