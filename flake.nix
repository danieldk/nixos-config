{
  inputs = {
    dwarffs = {
      url = "github:edolstra/dwarffs/83c13981993fa54c4cac230f2eec7241ab8fd0a9";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs-channels/nixos-unstable";
  };

  outputs = { self, dwarffs, nixpkgs }: {
    nixosConfigurations.mindbender = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        dwarffs.nixosModules.dwarffs
        machines/mindbender.nix
      ];
    };
  };
}
