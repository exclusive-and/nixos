{ config, pkgs, ... }:

{
    services.ddclient = {
        enable = true;

        username = "xandgate.com";
        passwordFile = "/etc/ddclient/xandgate-password";

        domains = [ "@" ];

        protocol = "namecheap";
        server = "dynamicdns.park-your-domain.com";
        use = "web, web=https://dynamicdns.park-your-domain.com/getip";
    };
}
