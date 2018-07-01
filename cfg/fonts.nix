# Font configuration.

{ config, pkgs, ... }:

{
  fonts = {
    enableFontDir = true;

    fonts = with pkgs; [
      corefonts
      google-fonts
      source-code-pro
    ];
  };
}
