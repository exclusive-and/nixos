{ config, pkgs, ... }:

let
    # Auto-login session; happens once on initial startup.
    initial_session = {
        command = "${pkgs.xorg.xinit}/bin/startx";
        user = "xand";
    };

    greetCmd = ''
        ${pkgs.greetd.tuigreet}/bin/tuigreet \
            --cmd ${pkgs.xorg.xinit}/bin/startx \
            --issue \
            --asterisks --asterisks-char "=" \
            --theme 'border=black;container=red;greet=white;prompt=white;input=black;button=yellow;action=red'
    '';

    # Greeter session.
    default_session = {
        command = greetCmd;
        user = "greeter";
    };
in
{
    environment.etc."issue".text = ''
        hyperion - NixOS 24.11
    '';

    services.greetd = {
        enable = true;
        settings = {
            inherit initial_session default_session;
        };
    };
}