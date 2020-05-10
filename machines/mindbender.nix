{ lib, config, pkgs, ... }:

let
  pwhash = import mindbender/pwhash.nix;
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  hardware = {
    cpu.intel.updateMicrocode = true;
    firmware = with pkgs; [
      firmwareLinuxNonfree
    ];
  };

  networking.hostName = "mindbender";

  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;

  nix = {
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/home/daniel/git/nixos-config/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Amsterdam";

  environment.shells = [
    pkgs.bashInteractive
    pkgs.zsh
  ];

  environment.systemPackages = with pkgs; [
     vim
  ];

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  networking.hostId = "1f2b819c";
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  users = {
    mutableUsers = false;

    users.root.hashedPassword = pwhash.root;

    users.daniel = {
      isNormalUser = true;
      hashedPassword = pwhash.daniel;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
  };

  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root -"
  ];

  system.stateVersion = "20.03";
}

