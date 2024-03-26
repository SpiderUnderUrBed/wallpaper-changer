{
  description = "Lets users automatically change wallpapers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, ... }:
    let
      # Systems that can run tests:
      supportedSystems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];

      # Function to generate a set based on supported systems:
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

      # Attribute set of nixpkgs for each system:
      nixpkgsFor = forAllSystems (system:
        import inputs.nixpkgs { inherit system; });
    in
    {
      homeManagerModules.wallpaper-changer = { ... }: {
        imports = [ ./modules ];
      };

      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system}; in
        {
          default = self.packages.${system}.node-runtime;

          node-runtime = pkgs.writeShellApplication {
            name = "node";
            runtimeInputs = with pkgs; [ nodejs ];
            text = ''node ./modules/kwin.js "$@"'';
          };

          demo = (inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              (import test/demo.nix {
                home-manager-module = inputs.home-manager.nixosModules.home-manager;
                wallpaper-changer = self.homeManagerModules.wallpaper-changer;
              })
              (_: {environment.systemPackages = [ self.packages.${system}.rc2nix]; })
            ];
          }).config.system.build.vm;

         
        });

      apps = forAllSystems (system: {
        default = self.apps.${system}.rc2nix;
 
        node=runtime = {
          type = "app";
          program = "${self.packages.${system}.node-runtime}/bin/node-runtime";
        };
      });

      checks = forAllSystems (system:
        {
          default = nixpkgsFor.${system}.callPackage ./test/basic.nix {
            home-manager-module = inputs.home-manager.nixosModules.home-manager;
            plasma-module = self.homeManagerModules.wallpaper-changer;
          };
        });

      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          buildInputs = with nixpkgsFor.${system}; [
            nodejs
          ];
        };
      });
    };
}
