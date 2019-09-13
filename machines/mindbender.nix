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
    packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
  };

  #boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];
  boot.kernelParams = [
    # Limit maximum ARC size to 4GB
    "zfs.zfs_arc_max=4294967296"
  ];
  boot.kernel.sysctl = {
    "kernel.perf_event_paranoid" = 0;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true; 
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.enableUnstable = true;

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };

  networking.hostName = "mindbender";
  networking.networkmanager.enable = false;

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
    git-crypt
    #nixops
  ];

  nix.buildCores = 4;
  nix.useSandbox = true;

  programs.bash.enableCompletion = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.vim.defaultEditor = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  # Services
  services.avahi = {
    enable = true;
    nssmdns = true;
  };
  services.openssh.enable = true;
  services.pcscd.enable = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];
  services.zfs.autoScrub.enable = true;
  services.xserver.videoDrivers = [ "intel" ];

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    checkReversePath = false;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 5353 ];
    allowedUDPPortRanges = [ { from = 32768; to = 61000; } ];
  };
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Hardware
  sound.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
      intel-ocl
    ];
  };
  hardware.u2f.enable = true;

  users.extraUsers.daniel = {
    createHome = true;
    home = "/home/daniel";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "cdrom" "libvirtd" "video" ];
    isNormalUser = true;
  };

  virtualisation.libvirtd.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

}
