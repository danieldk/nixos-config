{ lib, config, pkgs, ... }:

let
  pwhash = import mindbender/pwhash.nix;
  impermanence = (import ../nix/sources.nix).impermanence;
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../cfg/desktop-gnome3.nix
      (import "${impermanence}/nixos.nix")
    ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    extraModprobeConfig = ''
      options snd_hda_intel power_save=1
    '';

    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r rpool/local/root@blank
    '';

    kernel.sysctl = {
      "kernel.perf_event_paranoid" = 0;
    };

    kernelParams = [
      # Limit maximum ARC size to 4GB
      "zfs.zfs_arc_max=4294967296"
    ];

    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  environment = {
    persistence."/persist" = {
      directories = [
        "/etc/NetworkManager"
        "/etc/ssh"
        "/var/lib/bluetooth"
        "/var/lib/boltd"
        "/var/lib/fwupd"
        "/var/lib/cups"
        "/var/lib/docker"
        "/var/lib/libvirt"
        "/var/lib/NetworkManager"
        "/var/log"
      ];
      files = [
        "/etc/machine-id"
      ];
    };

    shells = [
      pkgs.bashInteractive
      pkgs.zsh
    ];

    systemPackages = with pkgs; [
      git
      git-crypt
      linuxPackages.perf
      softmaker-office
    ];
  };

  etc."NetworkManager/system-connections" = {
    source = "/persist/etc/NetworkManager/system-connections/";
  };
}

  hardware = {
    cpu.intel.updateMicrocode = true;

    firmware = with pkgs; [
      firmwareLinuxNonfree
    ];

    opengl = {
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

    sane = {
      enable = true;
      extraBackends = [ pkgs.hplipWithPlugin ];
    };

    u2f.enable = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  networking = {
    firewall = {
      enable = true;
      checkReversePath = false;
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 5353 ];
      allowedUDPPortRanges = [ { from = 32768; to = 61000; } ];
    };

    hostName = "mindbender";
    networkmanager.enable = false;
    useDHCP = false;
    interfaces.eno1.useDHCP = true;
  };

  nix = {
    buildCores = 4;
    maxJobs = 4;
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/home/daniel/git/nixos-config/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
    trustedUsers = [ "daniel" ];
    useSandbox = true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;

      packageOverrides = pkgs: {
        vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
      };
    };
  };

  time.timeZone = "Europe/Amsterdam";

  powerManagement.cpuFreqGovernor = "powersave";

  programs = {
    bash.enableCompletion = true;
    gnupg.agent = { enable = true; enableSSHSupport = true; };
    vim.defaultEditor = true;
    zsh.enable = true;
    zsh.enableCompletion = true;
  };

  services = {
    avahi = {
      enable = true;
      nssmdns = true;
    };

    fwupd.enable = true;

    interception-tools.enable = true;

    openssh = {
      enable = true;
    };

    pcscd.enable = true;

    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };

    udev.extraRules = ''
      # Solo Key
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a2ca", TAG+="uaccess", MODE="0660", GROUP="plugdev" 

      # Micro:Bit
      ATTRS{idVendor}=="0d28", ATTRS{idProduct}=="0204", GROUP="plugdev"

      # Jetvision ADS-B
      ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP:="plugdev"
    '';

    zfs.autoScrub.enable = true;
    xserver.videoDrivers = [ "intel" ];
  };

  sound.enable = true;

  systemd.tmpfiles.rules = [
    "L /etc/ipsec.secrets - - - - /etc/ipsec.d/ipsec.nm-l2tp.secrets"
  ];

  users = {
    mutableUsers = false;

    extraGroups.plugdev = { };

    users.root.hashedPassword = pwhash.root;

    users.daniel = {
      isNormalUser = true;
      hashedPassword = pwhash.daniel;
      extraGroups = [ "wheel" "cdrom" "libvirtd" "video" "plugdev" "dialout" "scanner" ];
      shell = pkgs.zsh;
      subGidRanges = [
        {
          count = 2048;
          startGid = 100001;
        }
      ];
      subUidRanges = [
        {
          count = 2048;
          startUid = 100001;
        }
      ];
    };
  };


  virtualisation.libvirtd.enable = true;

  system.stateVersion = "20.03";
}

