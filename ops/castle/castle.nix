{
  castle = { config, pkgs, libs, ... }: {
    imports = [
      ../../machines/castle.nix
    ];
  };
}
