{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_hardened;

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
  boot.kernel.sysctl."user.max_user_namespaces" = 0;
  boot.kernel.sysctl."vm.mmap_rnd_bits" = 32;
  boot.kernel.sysctl."vm.mmap_min_addr" = 65536;

  environment.systemPackages = with pkgs; [
    vim
  ];

  time.timeZone = "Europe/Amsterdam";

  users.extraUsers.daniel = {
    createHome = true;
    home = "/home/daniel";
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICjEndjSNA5r4F5fdM9ZL9v1xY5+vGXYGHBUAQGAt5h3"
    ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };

  security = {
    hideProcessInformation = true;
    lockKernelModules = true;
  };

  security.acme.certs = {
    "arch.danieldk.eu" = {
      email = "me@danieldk.eu";
    };

    "danieldk.eu" = {
      extraDomains = { "www.danieldk.eu" = null; };
      email = "me@danieldk.eu";
    };

    "dekok.dk" = {
      extraDomains = { "www.dekok.dk" = null; };
      email = "me@danieldk.eu";
    };

    "elaml.danieldk.eu" = {
      email = "me@danieldk.eu";
    };

    "flatpak.danieldk.eu" = {
      email = "me@danieldk.eu";
    };

    "ljdekok.com" = {
      extraDomains = { "www.ljdekok.com" = null; };
      email = "me@danieldk.eu";
    };

    "plantsulfur.org" = {
      extraDomains = { "www.plantsulfur.org" = null; };
      email = "me@danieldk.eu";
    };
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

    virtualHosts."apgc.eu" = {
      serverName = "apgc.eu";
      serverAliases = [ "www.apgc.eu" ];
      root = "/var/www/html";
      globalRedirect = "onlinelibrary.wiley.com/doi/full/10.1111/plb.12413";
    };

    virtualHosts."danieldk.eu" = {
      serverName = "danieldk.eu";
      serverAliases = [ "www.danieldk.eu" ];
      forceSSL = true;
      enableACME = true;
      root = "/srv/www/danieldk.eu";
    };

    virtualHosts."elaml.danieldk.eu" = {
      serverName = "elaml.danieldk.eu";
      forceSSL = true;
      enableACME = true;
      root = "/srv/www/elaml.danieldk.eu";
    };

    virtualHosts."flatpak.danieldk.eu" = {
      serverName = "flatpak.danieldk.eu";
      forceSSL = true;
      enableACME = true;
      extraConfig = "autoindex on;";
      root = "/srv/www/flatpak.danieldk.eu";
    };

    virtualHosts."arch.danieldk.eu" = {
      serverName = "arch.danieldk.eu";
      forceSSL = true;
      enableACME = true;
      extraConfig = "autoindex on;";
      root = "/srv/www/arch.danieldk.eu";
    };

    virtualHosts."dekok.dk" = {
      serverName = "dekok.dk";
      serverAliases = [ "www.dekok.dk" ];
      forceSSL = true;
      enableACME = true;
      root = "/srv/www/dekok.dk";
    };

    virtualHosts."ljdekok.com" = {
      serverName = "ljdekok.com";
      serverAliases = [ "www.ljdekok.com" ];
      forceSSL = true;
      enableACME = true;
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
      serverAliases = [ "www.plantsulfur.org" ];
      root = "/srv/www/plantsulfur.org/htdocs";
      forceSSL = true;
      enableACME = true;
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
