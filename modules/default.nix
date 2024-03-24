{ lib, ... }:
{
options.programs.wallpaper-changer.enable = lib.mkEnableOption ''
    Enable configuration management for KDE Plasma.
  '';
}
