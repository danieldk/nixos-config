# Font configuration.

{ config, pkgs, ... }:

{
  fonts = {
    enableFontDir = true;

    fonts = with pkgs; [
      corefonts
      google-fonts
      noto-fonts
      noto-fonts-emoji
      source-code-pro
    ];
  };
}
