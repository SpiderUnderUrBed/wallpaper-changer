{ config, lib, pkgs, ... }:

with import <nixpkgs> {};
let
  cfg = config.programs.wallpaper-changer;
 mainScript =  pkgs.writeText "main.js" (builtins.readFile ./main.js);
#  icon-theme = stdenv.mkDerivation rec {
#    pname = "uos-fulldistro-icons";
#    version = "1.0";#
#
#    src = fetchFromGitHub {
#      owner = "zayronxio";
#      repo = "uos-fulldistro-icons";
#      rev = "master";
#      sha256 = "0lnghszggbicgigga2l1ksx66xcipc29y6vq4walgkx6c7jkz65k";
#    };#
#    installPhase = ''
#      mkdir -p $out/share/icons
#      cp -r $src $out/share/icons/uos-fulldistro-icons
#    '';
#    meta = with lib; {
#      description = "Uos Full Distro Icon Theme";
#      homepage = "https://github.com/example/uos-fulldistro-icons";
#      license = licenses.mit;
#      maintainers = with maintainers; [shardseven];
#    };
# };

  script = pkgs.writeShellApplication {
           name = "main";
            runtimeInputs = [ pkgs.nodejs ];
            text = "echo ${icon-theme} && node ${mainScript} \"\$@\"";
            #  text = "node ${mainScript} "$(builtins.toJSON cfg)" \"\$@\"";
  };

# startupScriptType = lib.types.submodule {
#    options = {
#      text = lib.mkOption {set up themes nixos
#        type = lib.types.str;
#        description = "The content of the startup-script.";
#      };
##      priority = lib.mkOption {
#        type = lib.types.int;
#        description = "The priority for the execution of the script. Lower priority means earlier execution.";
#        default = 0;
#      };
#    };
#  };

in
{
   options.programs.wallpaper-changer.folder = lib.mkOption {
       type = lib.types.str;
       description = "The folder containing wallpapers for the wallpaper changer program.";
       default = "/path/to/wallpapers";  # Replace with the default folder path
    };
      config = lib.mkIf cfg.enable {
    home.activation.change-wallpapers = (lib.hm.dag.entryAfter [ "writeBoundary" ]
      ''
       $DRY_RUN_CMD ${script}/bin/main
      '');
  };
}
