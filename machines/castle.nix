{ config, lib, pkgs, ... }:

let
  secrets = import ../secrets.nix;
  unstable = import <nixos-unstable> {};
  cgit-groff = unstable.cgit.overrideDerivation (oldAttrs: {
    postPatch = unstable.cgit.postPatch + ''
      substituteInPlace filters/html-converters/man2html \
        --replace 'groff' '${pkgs.groff}/bin/groff'
    '';
  });
in {
  imports = [
    ./hardware-configuration.nix
  ];

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

  environment.etc = {
    "cgitrc".text = ''
      cache-size=1000
      cache-root=/run/cgit
      virtual-root=/
      root-title=danieldk.eu git repositories
      root-desc=Source code of various danieldk.eu projects

      enable-http-clone=1
      clone-url=https://$HTTP_HOST$SCRIPT_NAME/$CGIT_REPO_URL

      enable-blame=1
      enable-commit-graph=1
      enable-log-filecount=1
      enable-log-linecount=1
      snapshots=tar.gz zip

      source-filter=${cgit-groff}/lib/cgit/filters/syntax-highlighting.py

      about-filter=${cgit-groff}/lib/cgit/filters/about-formatting.sh

      repo.url=dpar
      repo.path=/var/lib/gitolite/repositories/dpar.git
      repo.desc=Neural network dependency parser
      repo.owner=Daniël de Kok

      repo.url=finalfrontier
      repo.path=/var/lib/gitolite/repositories/finalfrontier.git
      repo.desc=Skip-gram word embedding model with subword units
      repo.owner=Daniël de Kok
      repo.readme=master:README.md

      repo.url=finalfrontier-python
      repo.path=/var/lib/gitolite/repositories/finalfrontier-python.git
      repo.desc=Python binding for finalfrontier
      repo.owner=Daniël de Kok
      #repo.readme=master:README.md
    '';
  };

  environment.systemPackages = with pkgs; [
    git
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
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxQ5dl7Md+wbS5IzCjTV4MN3fyo+/aeVJFA6ITCq43lWMMmFluooGi078S8huWFZwjuphJota5g/M3Q/U3G7KiCfDZN4HwucPGT8NQFHntRKQ9DdjJfeD+zE3ZTdKYsXe3N5wI5KSIgZIWk6WA4viZLtVVFHrttDirC30g4H9Cx/OdoIzANDtWAOxkYNeTz/lFnawuzbUasVJsCxYJ7AI6BKhaYqR6Fr12ceHEtmXG5nsZ/r6rHqdZHCknvSx1lSbp/cLReWFvlxtipmbvFHAbaVoc1TsRwExvOw26eSOgjqNFKumriVeOTpIlaZXpzGy+tEHeymmN63fF1UmsHUHBw=="
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

    "git.danieldk.eu" = {
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
  services.openssh.permitRootLogin = "no";

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    
    commonHttpConfig = ''
      server_names_hash_bucket_size 64;
    '';

    virtualHosts = {
      "apgc.eu" = {
        serverName = "apgc.eu";
        serverAliases = [ "www.apgc.eu" ];
        root = "/var/www/html";
        globalRedirect = "onlinelibrary.wiley.com/doi/full/10.1111/plb.12413";
      };

      "danieldk.eu" = {
        serverName = "danieldk.eu";
        serverAliases = [ "www.danieldk.eu" ];
        forceSSL = true;
        enableACME = true;
        root = "/srv/www/danieldk.eu";
      };

      "elaml.danieldk.eu" = {
        serverName = "elaml.danieldk.eu";
        forceSSL = true;
        enableACME = true;
        root = "/srv/www/elaml.danieldk.eu";
      };

      "flatpak.danieldk.eu" = {
        serverName = "flatpak.danieldk.eu";
        forceSSL = true;
        enableACME = true;
        extraConfig = "autoindex on;";
        root = "/srv/www/flatpak.danieldk.eu";
      };

      "git.danieldk.eu" = {
        serverName = "git.danieldk.eu";
        forceSSL = true;
        enableACME = true;
        root = "${cgit-groff}/cgit";
        locations = {
          "/" = {
            extraConfig = ''
              try_files $uri @cgit;
            '';
          };
          "@cgit" = {
            extraConfig = ''
              uwsgi_pass unix:/run/uwsgi/cgit.sock;
              include ${pkgs.nginx}/conf/uwsgi_params;
              uwsgi_modifier1 9;
            '';
          };
        };
      };
    
      "arch.danieldk.eu" = {
        serverName = "arch.danieldk.eu";
        forceSSL = true;
        enableACME = true;
        extraConfig = "autoindex on;";
        root = "/srv/www/arch.danieldk.eu";
      };

      "dekok.dk" = {
        serverName = "dekok.dk";
        serverAliases = [ "www.dekok.dk" ];
        forceSSL = true;
        enableACME = true;
        root = "/srv/www/dekok.dk";
      };

      "ljdekok.com" = {
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

      "plantsulfur.org" = {
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
  };

  systemd.services.cgitcache = {
    description = "Create cache directory for cgit";
    enable = true;
    wantedBy = [ "uwsgi.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir /run/cgit
      chown -R nginx:nginx /run/cgit
    '';
  };

  services.gitolite = {
    enable = true;
    extraGitoliteRc = ''
      $RC{UMASK} = 0027;
    '';
    adminPubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxQ5dl7Md+wbS5IzCjTV4MN3fyo+/aeVJFA6ITCq43lWMMmFluooGi078S8huWFZwjuphJota5g/M3Q/U3G7KiCfDZN4HwucPGT8NQFHntRKQ9DdjJfeD+zE3ZTdKYsXe3N5wI5KSIgZIWk6WA4viZLtVVFHrttDirC30g4H9Cx/OdoIzANDtWAOxkYNeTz/lFnawuzbUasVJsCxYJ7AI6BKhaYqR6Fr12ceHEtmXG5nsZ/r6rHqdZHCknvSx1lSbp/cLReWFvlxtipmbvFHAbaVoc1TsRwExvOw26eSOgjqNFKumriVeOTpIlaZXpzGy+tEHeymmN63fF1UmsHUHBw== /Users/daniel/.ssh/id_rsa";
    user = "git";
    group = "git";
  };

  users.extraUsers.nginx.extraGroups = [ "git" ];

  services.uwsgi = {
    enable = true;
    user = "nginx";
    group = "nginx";
    plugins = [ "cgi" "python2" ];
    
    instance = {
      type = "emperor";
      
      vassals = {
        cgit = {
          type = "normal";
          master = "true";
          socket = "/run/uwsgi/cgit.sock";
          procname-master = "uwsgi cgit";
          plugins = [ "cgi" ];
          cgi = "${pkgs.cgit}/cgit/cgit.cgi";
        };

        ljdekok = {
          type = "normal";
          pythonPackages = self: with self; [ moinmoin ];
          master = true;
          socket = "/run/uwsgi/ljdekok.sock";
          wsgi-file = "${pkgs.python27Packages.moinmoin}/share/moin/server/moin.wsgi";
          chdir = "/srv/www/ljdekok.org";
          plugins = [ "python2" ];
        };

        plantsulfur = {
          type = "normal";
          pythonPackages = self: with self; [ moinmoin ];
          master = true;
          socket = "/run/uwsgi/plantsulfur.sock";
          wsgi-file = "${pkgs.python27Packages.moinmoin}/share/moin/server/moin.wsgi";
          chdir = "/srv/www/plantsulfur.org";
          plugins = [ "python2" ];
        };
      };
    };
  };
}
