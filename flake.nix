
{
    description = "hyperion OS configuration";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-24.11";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        challengerDeep = {
            url = "github:challenger-deep-theme/vim";
            flake = false;
        };
    };

    outputs = { nixpkgs, ... } @ inputs: {
        nixosConfigurations = {
            hyperion = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";

                modules = with inputs; [
                    ./configuration.nix
                ];
                
                specialArgs = {
                    inherit inputs;
                    inherit (inputs) challengerDeep;
                };
            };
        };
    };
}

