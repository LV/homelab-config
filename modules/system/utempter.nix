{ pkgs, ... }:

{
  # Keep tmux's privileged utmp helper at the system level.
  security.wrappers.utempter = {
    source = "${pkgs.libutempter}/lib/utempter/utempter";
    owner = "root";
    group = "utmp";
    setuid = false;
    setgid = true;
  };
}
