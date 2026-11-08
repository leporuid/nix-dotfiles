# Self-contained native NixOS configuration for Oracle Cloud ARM A1 (nixos).
{
  lib,
  pkgs,
  inputs,
  flake,
  vars,
  config,
  ...
}:
with inputs;
{
  # =========================================================================
  # 1. Imports
  # =========================================================================
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    agenix.nixosModules.default
    disko.nixosModules.disko
    determinate.nixosModules.default

    self.modules.common.vars
    "${nixpkgs}/nixos/modules/virtualisation/oci-image.nix"
  ];

  # =========================================================================
  # 2. Boot, Kernel & OCI Architecture (BBR & Jumbo Frames)
  # =========================================================================
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
      # Allow unprivileged processes to bind ports 80/443 without root
      "net.ipv4.ip_unprivileged_port_start" = 80;

      # BBR congestion control & FQ scheduler for optimal latency on Oracle Cloud
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";

      # Networking forwarding
      "net.core.devconf_inherit_init_net" = 1;
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.all.route_localnet" = lib.mkDefault 1;
      "net.ipv6.conf.all.forwarding" = lib.mkDefault 1;

      # Network buffer tuning for throughput bursts (from ThomasRitaine)
      "net.core.rmem_default" = 2097152;
      "net.core.rmem_max" = 16777216;
    };

    # APFS case-hack collision workaround for ncurses terminfo in initrd
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

  # Filesystem mounts managed via disko
  fileSystems."/".device = lib.mkForce "/dev/disk/by-label/nixos";
  fileSystems."/boot".device = lib.mkForce "/dev/disk/by-label/ESP";
  fileSystems."/boot".options = [ "umask=0077" ];

  systemd.targets.multi-user.enable = true;

  # Memory & Process Resilience (ZRAM swap & OOMD from junghan0611)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
  systemd.oomd.enable = true;

  # =========================================================================
  # 3. Networking, Firewall, Tailscale & Timesync
  # =========================================================================
  networking = {
    hostName = vars.hostname;
    useNetworkd = true;
    useDHCP = true;
    iproute2.enable = true;
    nftables.enable = true;

    firewall = {
      enable = true;
      checkReversePath = "loose";
      allowedTCPPorts = [ 22 80 443 8090 ];
      allowedUDPPorts = [ 41641 ];
      trustedInterfaces = [ "tailscale0" ];
    };
  };

  systemd.network = {
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
      # Enable Jumbo Frames for Oracle Cloud VCN internal network
      linkConfig.MTUBytes = "9000";
    };
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
    authKeyFile = config.age.secrets."tailscale-oracle".path;
    authKeyParameters.preauthorized = true;

    # Used at first login
    extraUpFlags = [
      "--reset"
      "--advertise-exit-node"
      "--accept-routes"
      "--accept-dns=false"
      "--ssh"
      "--advertise-routes=10.0.50.0/24"
      "--advertise-tags=tag:all"
    ];

    # Reapplied on every activation via `tailscale set`
    extraSetFlags = [
      "--advertise-exit-node"
      "--accept-routes"
      "--accept-dns=false"
      "--ssh"
      "--advertise-routes=10.0.50.0/24"
      "--advertise-tags=tag:all"
    ];
  };

  # Restart even after a clean exit (code 0), and never give up (from ThomasRitaine)
  systemd.services.tailscaled = {
    serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = "5s";
    };
    startLimitIntervalSec = 0;
  };

  systemd.services.tailscale-ethtool = {
    description = "Configure UDP GRO forwarding for Tailscale on default network interface";
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
        ethtool -K "$IFACE" rx-udp-gro-forwarding on rx-gro-list off || true
      fi
    '';
  };

  services.timesyncd = {
    enable = true;
    servers = [ "169.254.169.254" ];
    fallbackServers = [ "pool.ntp.org" ];
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "false";
      Domains = [ "~." ];
      FallbackDNS = [ "1.1.1.1" "8.8.8.8" ];
    };
  };

  services.vnstat.enable = true;

  # =========================================================================
  # 4. Security & Hardening (SSH, Fail2ban, Secrets)
  # =========================================================================
  services.openssh = {
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

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    bantime-increment.enable = true;
    ignoreIP = [ "100.0.0.0/8" ];
  };

  age = {
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    secrets = {
      tailscale-oracle.file = "${nix-secrets}/hosts/nixos/tailscale-oracle.age";
    };
  };

  security.sudo.wheelNeedsPassword = false;
  security.sudo.extraConfig = ''
    Defaults env_keep += "SSH_AUTH_SOCK"
  '';

  programs.ssh.knownHosts = {
    "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5A9WykxjBQj48tkmV";
  };
  security.sudo.extraRules = [
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

  # =========================================================================
  # 5. User & Interactive Shells (Bash Login -> Fish Interactive)
  # =========================================================================
  time.timeZone = vars.timezone;
  i18n.defaultLocale = vars.locale;

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.bashInteractive;
    users = {
      root = {
        hashedPassword = "!";
        openssh.authorizedKeys = {
          keys = vars.sshKeys;
          keyFiles = vars.sshKeyFiles;
        };
      };

      ${vars.username} = {
        isNormalUser = true;
        shell = pkgs.bashInteractive;
        extraGroups = [ "wheel" ];
        hashedPassword = "!";
        openssh.authorizedKeys = {
          keys = vars.sshKeys;
          keyFiles = vars.sshKeyFiles;
        };
      };
    };
  };

  programs.bash = {
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

      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING:-} ]] && tty -s; then
        if command -v fish >/dev/null 2>&1; then
          shopt -q login_shell && LOGIN_OPTION="--login" || LOGIN_OPTION=""
          exec "${pkgs.fish}/bin/fish" $LOGIN_OPTION
        fi
      fi
    '';
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile "${flake}/config/fish/config.fish";
  };

  # Symlink raw application configs from config/ to /etc/
  environment.etc = {
    # Expose the deployed system flake at /etc/nixos
    "nixos".source = flake;

    "direnv/direnv.toml".source = "${flake}/config/direnv/direnv.toml";
    "fish/completions".source = "${flake}/config/fish/completions";
    "fish/conf.d".source = "${flake}/config/fish/conf.d";
    "fish/functions".source = "${flake}/config/fish/functions";
    "jj/config.toml".source = "${flake}/config/jj/config.toml";
    "starship.toml".source = "${flake}/config/starship.toml";
    "configuration-revision".text = flake.rev or flake.dirtyRev;

    # Enforce a clean and standard /etc/shells without /nix/store clutter
    "shells".text = lib.mkForce ''
      /bin/sh
      /run/current-system/sw/bin/sh
      /run/current-system/sw/bin/bash
      /run/current-system/sw/bin/fish
    '';
  };

  environment.sessionVariables = {
    ATUIN_NOBIND = "true";
    BAT_THEME = "Catppuccin Mocha";
    DIRENV_CONFIG = "/etc/direnv/direnv.toml";
    JJ_CONFIG = "/etc/jj/config.toml";
    STARSHIP_CONFIG = "/etc/starship.toml";
  };

  # =========================================================================
  # 6. System Packages, Observability & Nix Core
  # =========================================================================
  environment.systemPackages = with pkgs; [
    age
    rage
    ((agenix.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      ageBin = "${pkgs.rage}/bin/rage";
    }).overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    }))
    ethtool

    # Observability & diagnostic tools
    lsof
    inetutils
    dig
    traceroute
    tcpdump

    # CLI essentials
    bashInteractive
    fish
    starship
    direnv
    nix-direnv
    zoxide
    fzf
    tmux
    zellij
    git
    gh
    ghostty.terminfo
    lazygit
    bat
    eza
    fd
    ripgrep
    curl
    wget
    jq
    yq-go
    htop
    btop
    mosh
    jujutsu
    just
    gum
    tree
    uv
    bun
    nushell
    helix
    vim
    neovim
    tealdeer
    nixfmt
    nix-output-monitor
    ast-grep
    delta
  ];

  services.journald.settings.Journal = {
    SystemMaxUse = "500M";
    MaxRetentionSec = "2week";
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:leporuid/nix-dotfiles";
    dates = "04:20";
    randomizedDelaySec = "45min";
    allowReboot = true;
    operation = "switch";
  };

  determinate.enable = true;

  nix.settings = {
    inherit (vars.caches) extra-substituters extra-trusted-public-keys;

    experimental-features = [
      "nix-command"
      "flakes"
    ];

    accept-flake-config = true;
    auto-optimise-store = true;
    builders-use-substitutes = true;
    connect-timeout = 5;
    fallback = true;
    http-connections = 50;
    keep-going = true;
    log-lines = 25;
    max-free = 3221225472;
    max-jobs = "auto";
    min-free = 1073741824;
    stalled-download-timeout = 20;
    warn-dirty = false;

    trusted-users = [
      "root"
      "leporuid"
    ];
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.channel.enable = false;
  nix.nixPath = [ ];
  nix.registry.nixpkgs.flake = nixpkgs;
  nix.registry.self.flake = flake;

  services.getty.autologinUser = null;

  documentation = {
    enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  system.stateVersion = "26.11";
}
