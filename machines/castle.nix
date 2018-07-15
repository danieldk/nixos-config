{ config, lib, pkgs, ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  
  boot.loader.grub.device = "/dev/vda";

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  environment.systemPackages = with pkgs; [
    vim
  ];

  time.timeZone = "Europe/Amsterdam";

  users.extraUsers.daniel = {
    createHome = true;
    home = "/home/daniel";
    extraGroups = [ "wheel" ];
    isNormalUser = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };

  security.acme.certs = {
    "danieldk.eu" = {
      extraDomains = { "www.danieldk.eu" = null; };
      email = "me@danieldk.eu";
    };

    "dekok.dk" = {
      extraDomains = { "www.dekok.dk" = null; };
      email = "me@danieldk.eu";
    };

    #"flatpak.danieldk.eu" = {
    #  email = "me@danieldk.eu";
    #};
  };

  services.openssh.enable = true;
    
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    
    commonHttpConfig = ''
      server_names_hash_bucket_size 64;
    '';

    virtualHosts."danieldk.eu" = {
      serverName = "danieldk.eu";
      serverAliases = [ "www.danieldk.eu" ];
      forceSSL = true;
      enableACME = true;
      root = "/srv/www/danieldk.eu";
    };

    virtualHosts."flatpak.danieldk.eu" = {
      serverName = "flatpak.danieldk.eu";
      #forceSSL = true;
      #enableACME = true;
      root = "/srv/www/flatpak.danieldk.eu";
    };

    virtualHosts."arch.danieldk.eu" = {
      serverName = "arch.danieldk.eu";
      root = "/srv/www/arch.danieldk.eu";
    };

    virtualHosts."dekok.dk" = {
      serverName = "dekok.dk";
      serverAliases = [ "www.dekok.dk" ];
      forceSSL = true;
      enableACME = true;
      root = "/srv/www/dekok.dk";
    };

    virtualHosts."ljdekok.org" = {
      serverName = "ljdekok.org";
      root = "/srv/www/ljdekok.org/htdocs";
      locations = {
        "/" = {
          extraConfig = ''
            uwsgi_pass unix:/run/uwsgi/ljdekok.sock;
            include ${pkgs.nginx}/conf/uwsgi_params;
          '';
        };
        "~ ^/wiki/(.*)" = {
          alias = "/srv/www/ljdekok.org/htdocs/$1";
        };
        "/robots.txt" = {
          alias = "/srv/www/ljdekok.org/htdocs/robots.txt";
        };
        "/favicon.ico" = {
          alias = "/srv/www/ljdekok.org/htdocs/favicon.ico";
        };
      };
    };

    virtualHosts."plantsulfur.org" = {
      serverName = "plantsulfur.org";
      root = "/srv/www/plantsulfur.org/htdocs";
      locations = {
        "/" = {
          extraConfig = ''
            uwsgi_pass unix:/run/uwsgi/plantsulfur.sock;
            include ${pkgs.nginx}/conf/uwsgi_params;
          '';
        };
        "~ ^/wiki/(.*)" = {
          alias = "/srv/www/plantsulfur.org/htdocs/$1";
        };
        "/robots.txt" = {
          alias = "/srv/www/plantsulfur.org/htdocs/robots.txt";
        };
        "/favicon.ico" = {
          alias = "/srv/www/plantsulfur.org/htdocs/favicon.ico";
        };
      };
    };
  };

  services.uwsgi = {
    enable = true;
    user = "nginx";
    group = "nginx";
    plugins = [ "python2" ];
    
    instance = {
      type = "emperor";
      
      vassals = {
        ljdekok = {
          type = "normal";
          pythonPackages = self: with self; [ moinmoin ];
          master = true;
          socket = "/run/uwsgi/ljdekok.sock";
          wsgi-file = "${pkgs.python27Packages.moinmoin}/share/moin/server/moin.wsgi";
          chdir = "/srv/www/ljdekok.org";
        };

        plantsulfur = {
          type = "normal";
          pythonPackages = self: with self; [ moinmoin ];
          master = true;
          socket = "/run/uwsgi/plantsulfur.sock";
          wsgi-file = "${pkgs.python27Packages.moinmoin}/share/moin/server/moin.wsgi";
          chdir = "/srv/www/plantsulfur.org";
        };
      };
    };
  };
}
