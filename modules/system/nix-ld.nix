_:

{
  # Support for tools that install themselves (e.g. Claude Code): nix-ld
  # runs their prebuilt generic-Linux binaries, and ~/.local/bin, where
  # such installers usually put them, goes on PATH.
  programs.nix-ld.enable = true;
  environment.localBinInPath = true;
}
