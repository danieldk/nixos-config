{
  syncnode = { config, pkgs, libs, ... }: {
    imports = [
      ../../machines/syncnode.nix
    ];
  };
}
