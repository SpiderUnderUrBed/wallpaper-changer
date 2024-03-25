{ config, lib, ... }:

let
  cfg = config.programs.plasma;
  startupScriptType = lib.types.submodule {
    options = {
      text = lib.mkOption {
        type = lib.types.str;
        description = "The content of the startup-script.";
      };
      priority = lib.mkOption {
        type = lib.types.int;
        description = "The priority for the execution of the script. Lower priority means earlier execution.";
        default = 0;
      };
    };
  };
in
{
   options.programs.wallpaper-changer.folder = lib.mkOption {
       type = lib.types.str;
       description = "The folder containing wallpapers for the wallpaper changer program.";
       default = "/path/to/wallpapers";  # Replace with the default folder path
    };
  options.programs.wallpaper-changer.startup = {
  
  };
}
