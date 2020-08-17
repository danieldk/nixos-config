{
  inputs = {
    dwarffs = {
      url = "github:edolstra/dwarffs/83c13981993fa54c4cac230f2eec7241ab8fd0a9";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:danieldk/impermanence/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs-channels/nixos-unstable";
  };

  outputs = { self, dwarffs, impermanence, nixpkgs }: {
    nixosConfigurations.mindbender = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        dwarffs.nixosModules.dwarffs
        impermanence.nixosModule
        machines/mindbender.nix
      ];
    };
  };
}
