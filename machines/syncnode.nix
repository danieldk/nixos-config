{ config, pkgs, ... }:

{
  # Kernel hardening.
  boot.kernelParams = [
    # Overwrite free'd memory
    "page_poison=1"

    # Disable legacy virtual syscalls
    "vsyscall=none"

    # Disable hibernation (allows replacing the running kernel)
    "nohibernate"
  ];

  boot.kernel.sysctl."kernel.kexec_load_disabled" = true;
  boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = true;
  boot.kernel.sysctl."net.core.bpf_jit_harden" = true;
  boot.kernel.sysctl."vm.mmap_rnd_bits" = 32;
  boot.kernel.sysctl."vm.mmap_min_addr" = 65536;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     vim
  ];

  nixpkgs.config.allowUnfree = true;

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  services.resilio = {
    enable = true;
    enableWebUI = true;
    deviceName = "syncnode";
    listeningPort = 44444;
    useUpnp = false;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 44444 ];
    allowedUDPPorts = [ 44444 ];
  };

  security = {
    hideProcessInformation = true;
    lockKernelModules = true;
  };

  users.extraUsers.daniel = {
    createHome = true;
    home = "/home/daniel";
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICjEndjSNA5r4F5fdM9ZL9v1xY5+vGXYGHBUAQGAt5h3"
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxQ5dl7Md+wbS5IzCjTV4MN3fyo+/aeVJFA6ITCq43lWMMmFluooGi078S8huWFZwjuphJota5g/M3Q/U3G7KiCfDZN4HwucPGT8NQFHntRKQ9DdjJfeD+zE3ZTdKYsXe3N5wI5KSIgZIWk6WA4viZLtVVFHrttDirC30g4H9Cx/OdoIzANDtWAOxkYNeTz/lFnawuzbUasVJsCxYJ7AI6BKhaYqR6Fr12ceHEtmXG5nsZ/r6rHqdZHCknvSx1lSbp/cLReWFvlxtipmbvFHAbaVoc1TsRwExvOw26eSOgjqNFKumriVeOTpIlaZXpzGy+tEHeymmN63fF1UmsHUHBw=="
    ];
  };

  system.stateVersion = "18.09"; # Did you read the comment?
}
