{ lib, config, pkgs, ... }:

let
  pwhash = import mindbender/pwhash.nix;
in {
  imports = [
      ../cfg/desktop-gnome3.nix
    ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];

      postDeviceCommands = lib.mkAfter ''
        zfs rollback -r rpool/local/root@blank
      '';
    };

    kernel.sysctl = {
      "kernel.perf_event_paranoid" = 0;
    };

    kernelModules = [ "kvm-amd" ];

    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      # Limit maximum ARC size to 4GB
      "zfs.zfs_arc_max=4294967296"
    ];

    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  #console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

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
      (softmaker-office.override {
        officeVersion = {
          edition = "2018";
          version = "978";
          sha256 = "14qnlbczq1zcz24vwy2yprdvhyn6bxv1nc1w6vjyq8w5jlwqsgbr";
        };
      })
    ];
  };

  fileSystems."/" =
    { device = "rpool/local/root";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B2FB-B410";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    { device = "rpool/local/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/safe/home";
      fsType = "zfs";
    };

  fileSystems."/persist" =
    { device = "rpool/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/c42c89b9-2efc-4688-8a03-1ef12b1a0fef"; }
    ];

  hardware = {
    cpu.amd.updateMicrocode = true;

    enableRedistributableFirmware = true;

    firmware = with pkgs; [
      firmwareLinuxNonfree
    ];

    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    };

    #nvidia.modesetting.enable = true;

    pulseaudio = {
      enable = true;
      support32Bit = true;
    };

    sane = {
      enable = true;
      extraBackends = [ pkgs.hplipWithPlugin ];
    };
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
      logRefusedConnections = false;
    };

    hostId = "353884b8";
    hostName = "mindbender";
    networkmanager.enable = true;
    useDHCP = false;
  };

  nix = {
    package = pkgs.nixUnstable;
    buildCores = 16;
    maxJobs = 8;
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/home/daniel/git/nixos-config/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
    trustedUsers = [ "daniel" ];
    useSandbox = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
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

  powerManagement.cpuFreqGovernor = "ondemand";

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
      forwardX11 = true;
    };

    pcscd.enable = true;

    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };

    udev.extraRules = ''
      # Solo Key
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a2ca", TAG+="uaccess"

      # Micro:Bit
      ATTRS{idVendor}=="0d28", ATTRS{idProduct}=="0204", GROUP="plugdev"

      # Jetvision ADS-B
      ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP:="plugdev"

      SUBSYSTEM=="usb", ATTR{idVendor}=="2516", ATTR{idProduct}=="0051", TAG+="uaccess"
    '';

    zfs.autoScrub.enable = true;
    xserver = {
      libinput = {
        enable = true;
        scrollButton = 8;
      };
      videoDrivers = [ "nvidia" ];
    };
    #xserver.displayManager.gdm.nvidiaWayland = true;
  };

  systemd.services.display-manager.restartIfChanged = false;

  systemd.tmpfiles.rules = [
    "L /etc/ipsec.secrets - - - - /etc/ipsec.d/ipsec.nm-l2tp.secrets"
  ];

  users = {
    mutableUsers = false;

    extraGroups.plugdev = { };

    users.root.hashedPassword = pwhash.root;

    users = {
      daniel = {
        isNormalUser = true;
        hashedPassword = pwhash.daniel;
        extraGroups = [ "wheel" "audio" "cdrom" "docker" "libvirtd" "video" "plugdev" "dialout" "scanner" ];
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

      reviewer = {
        isNormalUser = true;
        createHome = true;
      };
    };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  system.stateVersion = "20.03";
}

