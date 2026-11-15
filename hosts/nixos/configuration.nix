# Self-contained native NixOS configuration for Oracle Cloud ARM A1 (nixos).
{
  inputs,
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  inherit (inputs) nix-secrets;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.determinate.nixosModules.default
    inputs.self.nixosModules.aggregate
    "${inputs.nixpkgs}/nixos/modules/virtualisation/oci-image.nix"
  ]
  ++ lib.optional (inputs ? nixos-facter-modules) inputs.nixos-facter-modules.nixosModules.facter;

  hardware.facter.reportPath = lib.mkIf (
    (inputs ? nixos-facter-modules) && builtins.pathExists ./facter.json
  ) ./facter.json;

  oci.efi = true;

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false;
      };

      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
    };

    kernel.sysctl = {
      "net.ipv4.ip_unprivileged_port_start" = 80;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.devconf_inherit_init_net" = 1;
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.all.route_localnet" = lib.mkDefault 1;
      "net.ipv6.conf.all.forwarding" = lib.mkDefault 1;
      "net.core.rmem_default" = 2097152;
      "net.core.rmem_max" = 16777216;
    };

    initrd.systemd.contents."/etc/terminfo/l/linux".source = lib.mkForce (
      pkgs.runCommand "initrd-terminfo-linux" { } ''
        if [ -f "${pkgs.ncurses}/share/terminfo/l/linux" ]; then
          cp "${pkgs.ncurses}/share/terminfo/l/linux" "$out"
        else
          cp ${pkgs.ncurses}/share/terminfo/l*case*hack*/linux "$out"
        fi
      ''
    );
  };

  fileSystems = {
    "/".device = lib.mkForce "/dev/disk/by-label/nixos";

    "/boot" = {
      device = lib.mkForce "/dev/disk/by-label/ESP";
      options = [ "umask=0077" ];
    };
  };

  systemd = {
    targets.multi-user.enable = true;

    services = {
      "serial-getty@ttyAMA0".enable = false;

      tailscaled = {
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = "5s";
        };
        startLimitIntervalSec = 0;
      };

      tailscale-ethtool = {
        description = "Configure UDP GRO forwarding for Tailscale";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        path = with pkgs; [
          iproute2
          ethtool
          gawk
        ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        script = ''
          IFACE="$(ip -4 route show default | awk '{print $5; exit}')"
          if [ -n "$IFACE" ]; then
            ethtool -K "$IFACE" \
              rx-udp-gro-forwarding on \
              rx-gro-list off || true
          fi
        '';
      };

      iroh-ssh = {
        description = "Iroh P2P SSH Server";
        after = [
          "network-online.target"
          "sshd.service"
        ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.iroh-ssh}/bin/iroh-ssh server --persist --key-dir /var/lib/iroh-ssh";
          Restart = "always";
          RestartSec = "10s";
          StateDirectory = "iroh-ssh";
          WorkingDirectory = "/var/lib/iroh-ssh";
        };
      };
    };

    oomd.enable = true;

    network = {
      enable = true;
      wait-online.anyInterface = true;

      networks."10-eth" = {
        matchConfig = {
          Name = "ens*";
          Type = "ether";
        };

        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = true;
        };

        linkConfig.MTUBytes = "9000";
      };
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  networking = {
    hostName = "nixos";
    useNetworkd = true;
    useDHCP = true;
    iproute2.enable = true;
    nftables.enable = true;

    firewall = {
      enable = true;
      checkReversePath = "loose";

      allowedTCPPorts = [
        22
        80
        443
        8090
      ];

      allowedUDPPorts = [ 41641 ];
      trustedInterfaces = [ "tailscale0" ];
    };
  };

  services = {
    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "both";
      authKeyFile = config.age.secrets.tailscale-oracle.path;
      authKeyParameters.preauthorized = true;

      extraUpFlags = [
        "--reset"
        "--advertise-exit-node"
        "--accept-routes"
        "--accept-dns=false"
        "--ssh"
        "--advertise-tags=tag:all"
      ];

      extraSetFlags = [
        "--advertise-exit-node"
        "--accept-routes"
        "--accept-dns=false"
        "--ssh"
        "--advertise-tags=tag:all"
      ];
    };

    timesyncd = {
      enable = lib.mkForce true;
      servers = [ "169.254.169.254" ];
      fallbackServers = [ "pool.ntp.org" ];
    };

    resolved = {
      enable = true;

      settings.Resolve = {
        DNSSEC = "false";
        Domains = [ "~." ];
        FallbackDNS = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    };

    vnstat.enable = true;

    openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
        ClientAliveInterval = 60;
        ClientAliveCountMax = 3;
        X11Forwarding = false;

        AcceptEnv = [
          "COLORTERM"
          "TERM_PROGRAM"
          "TERM_PROGRAM_VERSION"
        ];
      };
    };

    fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "1h";
      bantime-increment.enable = true;
      ignoreIP = [ "100.0.0.0/8" ];
    };

    journald.settings.Journal = {
      SystemMaxUse = "500M";
      MaxRetentionSec = "2week";
    };

    getty.autologinUser = null;

    fstrim = {
      enable = true;
      interval = "weekly";
    };
  };

  age = {
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    secrets.tailscale-oracle = {
      file = "${nix-secrets}/hosts/nixos/tailscale-oracle.age";
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  security = {
    sudo = {
      wheelNeedsPassword = false;

      extraConfig = ''
        Defaults env_keep += "SSH_AUTH_SOCK"
      '';

      extraRules = [
        {
          users = [ vars.username ];

          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
  };

  programs = {
    ssh.knownHosts = {
      "github.com".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5A9WykxjBQj48tkmV";
    };

    bash = {
      completion.enable = true;

      interactiveShellInit = ''
        export HISTFILE="$HOME/.local/share/bash/.bash_history"
        export HISTSIZE=10000
        export HISTFILESIZE=20000
        export HISTCONTROL="ignoreboth:erasedups"

        shopt -s histappend
        shopt -s cmdhist
        shopt -s lithist

        add_to_path() {
          case ":$PATH:" in
            *":$1:"*)
              ;;
            *)
              PATH="$1:$PATH"
              ;;
          esac
        }

        add_to_path "$HOME/.local/bin"
        export PATH

        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "nu" &&
          -z ''${BASH_EXECUTION_STRING:-} ]] && tty -s; then
          if command -v nu >/dev/null 2>&1; then
            if shopt -q login_shell; then
              LOGIN_OPTION="--login"
            else
              LOGIN_OPTION=""
            fi

            exec "${pkgs.nushell}/bin/nu" $LOGIN_OPTION
          fi
        fi
      '';
    };

    fish = {
      enable = true;
      useBabelfish = true;

      interactiveShellInit = ''
        if test "$TERM" = "dumb"
          function fish_prompt
            echo "\$ "
          end

          function fish_right_prompt; end
          function fish_greeting; end
          function fish_title; end
        end
      '';
    };
  };

  time.timeZone = vars.timezone;
  i18n.defaultLocale = vars.locale;

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.bashInteractive;

    users = {
      root = {
        hashedPassword = "!";
        openssh.authorizedKeys.keyFiles = vars.sshKeyFiles;
      };

      ${vars.username} = {
        isNormalUser = true;
        shell = pkgs.bashInteractive;
        extraGroups = [ "wheel" ];
        hashedPassword = "!";
        openssh.authorizedKeys.keyFiles = vars.sshKeyFiles;
      };
    };
  };

  environment = {
    etc = {
      nixos.source = inputs.self;

      configuration-revision.text = inputs.self.rev or inputs.self.dirtyRev or "dirty";

      "determinate/config.json".text = builtins.toJSON {
        garbageCollector.strategy = "automatic";
        telemetry.sentry.endpoint = null;
      };

      shells.text = lib.mkForce ''
        /bin/sh
        /run/current-system/sw/bin/sh
        /run/current-system/sw/bin/bash
        /run/current-system/sw/bin/fish
        /run/current-system/sw/bin/nu
      '';
    };

    systemPackages = with pkgs; [
      age
      rage

      (
        (inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
          ageBin = "${pkgs.rage}/bin/rage";
        }).overrideAttrs
          (_: {
            doCheck = false;
            doInstallCheck = false;
          })
      )

      ethtool
      lsof
      inetutils
      dig
      traceroute
      tcpdump
      bashInteractive
      fish
      nushell
      iroh-ssh
      nixos-facter
      git
      ghostty.terminfo
      curl
      wget
      yq-go
      htop
      btop
      mosh
      vim
    ];
  };

  system = {
    autoUpgrade = {
      enable = true;
      flake = "github:leporuid/nix-dotfiles";
      dates = "04:20";
      randomizedDelaySec = "45min";
      allowReboot = true;
      operation = "switch";
    };

    stateVersion = "26.11";
  };

  determinate.enable = true;

  nix = {
    settings =
      inputs.self.lib.nixSettings {
        inherit (vars) username;
      }
      // {
        auto-optimise-store = true;
      };

    optimise.automatic = true;
    channel.enable = false;
    nixPath = [ ];

    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      self.flake = inputs.self;
    };
  };

  documentation.man.cache.enable = false;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
