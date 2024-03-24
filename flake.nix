#{ pkgs, lib, config, ...}:
{
  description = "Manage KDE Plasma with Home Manager";

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

      # Function to create wallpaper-changer module for specified folder:
      wallpaperChanger = folder: { ... }: {
        imports = [ ./modules ];
        config = {
          homeManagerConfiguration = {
            scripts = {
              "change-wallpaper.sh" = {
                text = ''
                  #!/bin/sh
                  while true; do
                    # Command to change wallpaper
                    # For example, using feh to change wallpaper:
                    feh --bg-fill "${folder}"
                    sleep 60  # Change wallpaper every minute (60 seconds)
                  done
                '';
                executable = true;
              };
            };
          };
          systemd.user.services.change-wallpaper = {
            description = "Change wallpaper every minute";
            wantedBy = [ "default.target" ];
            serviceConfig = {
              Type = "simple";
              ExecStart = "${pkgs.stdenv.shell}/bin/sh -c ${config.homeManagerConfiguration.scripts.change-wallpaper.sh.text}";
              Restart = "on-failure";
            };
          };
        };
      };
    in
    {
      homeManagerModules.wallpaper-changer = { wallpaperChanger }: {};
      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system}; in
        {
          wallpaper = pkgs.writeShellApplication {
            name = "wallpaper";
            test = "";
          };
          apps  = forAllSystems (system: {
            default = self.packages.${system}.wallpaper;
            wallpaper = {
              type = "app";
              program = "";
            };
          });
        }
      );
    };
}
