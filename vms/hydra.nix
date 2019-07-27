{
  hydra = { config, pkgs, lib, ... }: {
    imports = [
      ../cfg/hydra.nix
    ];

    nixpkgs.config = {
      allowUnfree = true;
    };

    system.activationScripts.nixops-vm-fix = {
      text = ''
        if ls -l /nix/store | grep sudo | grep -q nogroup; then
        mount -o remount,rw  /nix/store
        chown -R root:nixbld /nix/store
        fi
      '';
      deps = [];
    };

    users.extraUsers = {
      daniel = {
        createHome = true;
        home = "/home/daniel";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICjEndjSNA5r4F5fdM9ZL9v1xY5+vGXYGHBUAQGAt5h3"
          "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxQ5dl7Md+wbS5IzCjTV4MN3fyo+/aeVJFA6ITCq43lWMMmFluooGi078S8huWFZwjuphJota5g/M3Q/U3G7KiCfDZN4HwucPGT8NQFHntRKQ9DdjJfeD+zE3ZTdKYsXe3N5wI5KSIgZIWk6WA4viZLtVVFHrttDirC30g4H9Cx/OdoIzANDtWAOxkYNeTz/lFnawuzbUasVJsCxYJ7AI6BKhaYqR6Fr12ceHEtmXG5nsZ/r6rHqdZHCknvSx1lSbp/cLReWFvlxtipmbvFHAbaVoc1TsRwExvOw26eSOgjqNFKumriVeOTpIlaZXpzGy+tEHeymmN63fF1UmsHUHBw=="
        ];
      };
    };
  };
}
