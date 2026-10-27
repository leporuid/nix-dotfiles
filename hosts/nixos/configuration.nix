# Self-contained native NixOS configuration for Oracle Cloud ARM A1 (nixos).
{
  lib,
  pkgs,
  inputs,
  flake,
  vars,
  config,
  nixCaches,
  ...
}:

let
  agenixPkg =
    (inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      ageBin = "${pkgs.rage}/bin/rage";
    }).overrideAttrs
      (_: {
        doCheck = false;
        doInstallCheck = false;
      });
in
{
  # =========================================================================
  # 1. Imports
  # =========================================================================
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.determinate.nixosModules.default

    inputs.self.modules.common.vars
    "${inputs.nixpkgs}/nixos/modules/virtualisation/oci-image.nix"
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
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };

    kernel.sysctl = {
      # BBR congestion control & FQ scheduler for optimal latency on Oracle Cloud
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";

      # Networking forwarding
      "net.core.devconf_inherit_init_net" = 1;
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.all.route_localnet" = lib.mkDefault 1;
      "net.ipv6.conf.all.forwarding" = lib.mkDefault 1;
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
    extraSetFlags = [
      "--accept-dns=false"
      "--accept-routes"
      "--advertise-exit-node"
      "--advertise-routes=10.0.50.0/24,169.254.169.254/32"
      "--advertise-tags=tag:all,tag:border0-managed"
    ];
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
      PermitRootLogin = "no";
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
      "/etc/nixos/secrets/keys.txt"
    ];
    secrets = {
      tailscale-oracle.file = ./tailscale-oracle.age;
      tailzero-invite.file = ./tailzero-invite.age;
    };
  };

  security.sudo.wheelNeedsPassword = false;
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
    users.${vars.username} = {
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
    "direnv/direnv.toml".source = "${flake}/config/direnv/direnv.toml";
    "fish/completions".source = "${flake}/config/fish/completions";
    "fish/conf.d".source = "${flake}/config/fish/conf.d";
    "fish/functions".source = "${flake}/config/fish/functions";
    "jj/config.toml".source = "${flake}/config/jj/config.toml";
    "starship.toml".source = "${flake}/config/starship.toml";
    "configuration-revision".text = flake.rev or flake.dirtyRev or "unknown";
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
    agenixPkg
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
    flake = "~/nix-dotfiles";
    dates = "04:20";
    randomizedDelaySec = "45min";
    allowReboot = true;
    operation = "switch";
  };

  determinate.enable = true;

  nix.settings = {
    inherit (nixCaches) extra-substituters extra-trusted-public-keys;

    experimental-features = [
      "nix-command"
      "flakes"
      "parallel-eval"
    ];

    accept-flake-config = true;
    auto-optimise-store = true;
    builders-use-substitutes = true;
    connect-timeout = 5;
    eval-cores = 0;
    fallback = true;
    http-connections = 50;
    keep-going = true;
    lazy-trees = true;
    log-lines = 25;
    max-free = 3221225472;
    max-jobs = "auto";
    min-free = 1073741824;
    stalled-download-timeout = 20;
    warn-dirty = false;

    trusted-users = [
      "leporuid"
    ];
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.registry.self.flake = flake;

  services.getty.autologinUser = null;

  documentation = {
    enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  system.stateVersion = "24.11";
}
