{ config, pkgs, inputs, ... }:

let
    challengerDeep = pkgs.vimUtils.buildVimPlugin {
        name = "challenger-deep";
        src  = inputs.challengerDeep;
    };

    myVim = pkgs.vim_configurable.customize {
        name = "vim";

        vimrcConfig = {
            packages.myPlugins = with pkgs.vimPlugins; {
                start = [
                    vim-nix
                    vim-lastplace
                    haskell-vim
                    challengerDeep
                ];
                opt = [];
            };

            customRC = builtins.readFile ./vimrc;
        };
    };

in
{
    environment.systemPackages = [ myVim ];
}
