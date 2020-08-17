{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs-channels/nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.mindbender = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ machines/mindbender.nix ];
    };
  };
}
