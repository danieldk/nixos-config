let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/nixos-19.09.tar.gz";
  }) {};
  addDeployment = machineConfig: deploy: args@{ config, lib, pkgs, ... }:
    machineConfig args // { deployment = deploy; };
in {
  network = {
    pkgs = pkgs // { overlays = []; };
    description = "Personal VPSes";
  };

  "castle.danieldk.eu" = import ../machines/castle.nix;

  "mindfuzz" = import ../machines/mindfuzz.nix;

  "syncnode.dekok.dk" = addDeployment (import ../machines/syncnode.nix) {
    healthChecks = {
      http = [
        {
          scheme = "https";
          port = 443;
          host = "blob.danieldk.eu";
          description = "Check whether blob.danieldk.eu is reachable.";
        }
      ];
    };
  };
}
