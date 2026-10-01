_:

{
  # Run prebuilt generic-Linux binaries that aren't packaged for Nix
  # (e.g. installer-downloaded tools like Plannotator).
  programs.nix-ld.enable = true;
  environment.localBinInPath = true;
}
