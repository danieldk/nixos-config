{
  syncnode = {
    imports = [
      <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ];

    deployment.targetEnv = "none";
    deployment.targetHost = "116.202.99.33";

    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.grub.device = "/dev/sda";
    boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sd_mod" "sr_mod" ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/7d2d9337-c2d8-4e52-955e-cb8d48b953d8";
        fsType = "ext4";
      };

    fileSystems."/storage" =
      { device = "/dev/disk/by-id/scsi-0HC_Volume_2687473";
        fsType = "ext4";
        options = [ "discard" "nofail" "defaults" ];
      };

    swapDevices = [ ];
  };
}
