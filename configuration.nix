{ config, pkgs, ... }:

let
    hostName = "hyperion";

    kernelPackages = pkgs.linuxPackages;

    # Me; the main user of hyperion.
    xand = {
        extraGroups = [
            "audio"
            "wheel"
        ];
        isNormalUser = true;
        shell = pkgs.fish;
    };

    xmonad = {
        enable = true;
        enableContribAndExtras = true;
    };

    defaultSession = "none+xmonad";

    systemPackages = with pkgs; [
        alacritty
        curl
        dmenu
        feh
        lshw
        wget
    ];
in
{
    boot = {
        inherit kernelPackages;

        loader = {
            efi.canTouchEfiVariables = true;
            grub = {
                efiSupport = true;
                useOSProber = true;
            };
            systemd-boot.enable = true;
        };
    };

    imports = [
        ./hardware-configuration.nix

        ./programs/slack
        ./programs/vim
    ];

    console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
    };

    hardware = {
        graphics = {
            enable = true;
            # enable32Bit = true;
            # extraPackages = with pkgs; [
            #     libGL
            # ];
        };

        nvidia = {
            modesetting.enable = false;
            nvidiaSettings = true;
            open = true;
            package = config.boot.kernelPackages.nvidiaPackages.beta;
            powerManagement = {
                enable = false;
                finegrained = false;
            };
        };
    };

    environment = {
        sessionVariables = {
            LIBVA_DRIVER_NAME   = "nvidia";
            GBM_BACKEND         = "nvidia-drm";
            __GL_GSYNC_ALLOWED  = "1";
            __GL_VRR_ALLOWED    = "1";
            NVD_BACKEND         = "direct";
        };

        inherit systemPackages;
    };

    i18n = {
        defaultLocale = "en_US.UTF-8";

        extraLocaleSettings = {
            LANG    = "en_CA.UTF-8";
            LC_TIME = "C";
        };

        supportedLocales = [
            "en_US.UTF-8/UTF-8"
            "en_CA.UTF-8/UTF-8"
        ];
    };

    networking = {
        inherit hostName;

        defaultGateway = {
            address = "192.168.2.1";
            interface = "eno1";
        };

        firewall.allowedTCPPorts = [
            22  # ssh
        ];

        interfaces.eno1 = {
            ipv4.addresses = [
                {
                    address = "192.168.2.20";
                    prefixLength = 24;
                }
            ];
            useDHCP = false;
        };

        nameservers = [ "192.168.2.1" ];

        useDHCP = false;
    };

    nix = {
        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
        };

        settings = {
            auto-optimise-store = true;
            experimental-features = [
                "flakes"
                "nix-command"
            ];
            trusted-users = [
                "root"
                "xand"
                "@wheel"
            ];
            warn-dirty = false;
        };
    };

    # Allow unfree Nix packages.
    #
    # Needed for installing some drivers (nvidia, broadcom).
    nixpkgs.config.allowUnfree = true;

    programs.fish.enable = true;

    security.rtkit.enable = true;

    services = {
        dbus.enable = true;

        displayManager = {
            autoLogin = {
                enable = true;
                user = "xand";
            };

            inherit defaultSession;
        };

        openssh.enable = true;

        pipewire = {
            enable = true;
            alsa.enable = true;
            audio.enable = true;
            jack.enable = true;
            pulse.enable = true;
            wireplumber.enable = true;
            extraConfig.pipewire."10-clock-rates" = {
                "context.properties" = {
                    "audio.format" = "s32le";
                    # "default.clock.rate" = 192000;
                    # "default.clock.allowed-rates" = [
                    #     192000
                    #     96000
                    #     48000
                    #     44100
                    # ];
                };
            };
        };

        seatd.enable = true;

        sshd.enable = true;

        xserver = {
            enable = true;

            displayManager.lightdm = {
                enable = true;
                greeters.tiny.enable = true;
            };

            monitorSection = ''
                Option "DPMS" "false"
            '';

            screenSection = ''
                Option "metamodes" "1920x1080_144 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
            '';

            serverLayoutSection = ''
                Option "StandbyTime" "0"
                Option "SuspendTime" "0"
                Option "OffTime"     "0"
            '';

            verbose = 7;

            videoDrivers = [ "nvidia" ];

            windowManager.xmonad = xmonad;

            xkb.layout = "us";
        };
    };

    # See https://nixos.org/nixos/options.html.
    system.stateVersion = "20.09";

    users.users = {
        inherit xand;
    };
}