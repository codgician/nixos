{
  description = "NixOS configuration with flakes";
  
  inputs = {
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nixos-cn = {
      url = "github:nixos-cn/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, nixos-cn }: 
    let system = "x86_64-linux";
    in {
      nixosConfigurations.Shijia-S540 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
          nixos-hardware.nixosModules.common-gpu-amd
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-pc-laptop-acpi_call
          nixos-hardware.nixosModules.common-pc-laptop
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.codgi = import ./home.nix;
          }
          ({ ... }: {
             environment.systemPackages = [ 
                nixos-cn.legacyPackages.${system}.netease-cloud-music
                nixos-cn.legacyPackages.${system}.howdy
             ];
             nix.binaryCaches = [
               "https://nixos-cn.cachix.org"
             ];
             nix.binaryCachePublicKeys = [ "nixos-cn.cachix.org-1:L0jEaL6w7kwQOPlLoCR3ADx+E3Q8SEFEcB9Jaibl0Xg=" ];

             imports = [
               nixos-cn.nixosModules.nixos-cn-registries
               nixos-cn.nixosModules.nixos-cn
             ];
          })
        ];
      };
    };
}
