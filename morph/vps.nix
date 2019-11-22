let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/nixos-19.03.tar.gz";
  }) {};
in {
  network = {
    pkgs = pkgs // { overlays = []; };
    description = "Personal VPSes";
  };

  "syncnode.dekok.dk" = import ../machines/syncnode.nix;
}
