{ config, lib, pkgs, ... }:

let
  secrets = import ../secrets.nix;
  unstable = import <nixos-unstable> {};
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
  boot.kernel.sysctl."user.max_user_namespaces" = 1;
  boot.kernel.sysctl."vm.mmap_rnd_bits" = 32;
  boot.kernel.sysctl."vm.mmap_min_addr" = 65536;

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

    "grafana.dekok.dk" = {
      email = "me@danieldk.eu";
    };

    "mqtt.dekok.dk" = {
      email = "me@danieldk.eu";
    };

    "scratch.doerte.eu" = {
      email = "me@doerte.eu";
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

    "scratch.danieldk.eu" = {
      email = "me@danieldk.eu";
    };

    "wordrepr.danieldk.eu" = {
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

  services.gitea = {
    enable = true;
    cookieSecure = true;
    database.type = "sqlite3";
    domain = "gitea.danieldk.eu";
    extraConfig = ''
      [service]
      DISABLE_REGISTRATION = true
      
      [U2F]
      APP_ID = https://gitea.danieldk.eu:443/
      TRUSTED_FACETS = https://gitea.danieldk.eu:443/
    '';
    httpAddress = "127.0.0.1";
    rootUrl = "https://gitea.danieldk.eu/";
  };

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

      "arch.danieldk.eu" = {
        serverName = "arch.danieldk.eu";
        forceSSL = true;
        enableACME = true;
        extraConfig = "autoindex on;";
        root = "/srv/www/arch.danieldk.eu";
      };

      "scratch.danieldk.eu" = {
        serverName = "scratch.danieldk.eu";
        forceSSL = true;
        enableACME = true;
        extraConfig = "autoindex on;";
        root = "/srv/www/scratch.danieldk.eu";
      };

      "wordrepr.danieldk.eu" = {
        serverName = "wordrepr.danieldk.eu";
        forceSSL = true;
        enableACME = true;
        root = "/srv/www/wordrepr.danieldk.eu";
      };

      "dekok.dk" = {
        serverName = "dekok.dk";
        serverAliases = [ "www.dekok.dk" ];
        forceSSL = true;
        enableACME = true;
        root = "/srv/www/dekok.dk";
      };

      "grafana.dekok.dk" = {
        serverName = "grafana.dekok.dk";
        forceSSL = true;
        enableACME = true;
        root = "/var/www/html";
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:3000/";
          };
        };
      };

      "mqtt.dekok.dk" = {
        serverName = "mqtt.dekok.dk";
        forceSSL = true;
        enableACME = true;
        root = "/srv/www/mqtt.dekok.dk";
      };

      "scratch.doerte.eu" = {
        serverName = "scratch.doerte.eu";
        extraConfig = "autoindex on;";
        forceSSL = true;
        enableACME = true;
        root = "/home/doerte/scratch.doerte.eu";
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

  services.grafana = {
    enable = true;
    analytics.reporting.enable = false;
    package = unstable.grafana;
  };

  services.mosquitto = {
    enable = true;
    host = "0.0.0.0";
    checkPasswords = true;
    ssl = {
      enable = true;
      #cafile = "/var/lib/mosquitto/ca.crt";
      #certfile = "/var/lib/mosquitto/server.crt";
      #keyfile = "/var/lib/mosquitto/server.key";
      cafile = "/var/lib/mosquitto/fullchain.pem";
      certfile = "/var/lib/mosquitto/fullchain.pem";
      keyfile = "/var/lib/mosquitto/key.pem";
    };
    extraConf = "require_certificate false";
    users = {
       sensornode = {
         acl = ["topic readwrite sensor/#" ];
         password = "player.sect.kay.manacle.afire";
       };
       smartmeter = {
         acl = ["topic readwrite smartmeter/#" ];
         password = "viand.sware.daunt.touch.receptor";
       };
       telegraf = {
         acl = ["topic readwrite sensor/#" "topic readwrite smartmeter/#" ];
         password = "player.sect.kay.manacle.afire";
       };
    };
  };

  services.influxdb = {
    enable = true;
    #extraConfig = {
    #  http = {
    #    enabled = true;
    #    bind-address = ":8086";
    #    auth-enabled = true;
    #    log-enabled = true;
    #    write-tracing = false;
    #    pprof-enabled = false;
    #  };
    #};
  };

  services.telegraf = {
    enable = true;
    extraConfig = {
      inputs = {
        mqtt_consumer = {
          servers = ["tcp://localhost:1883"];
          username = "telegraf";
          password = "player.sect.kay.manacle.afire";
          qos = 0;
          topics = [ "sensor/#" "smartmeter/#" ];
        };
      };
      outputs = {
        influxdb = {
          database = "sensors";
          urls = [ "http://localhost:8086" ];
        };
      };
    };
  };


  services.uwsgi = {
    enable = true;
    user = "nginx";
    group = "nginx";
    plugins = [ "cgi" "python2" ];
    
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
