_:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true; # EDITOR/VISUAL = nvim
    initLua = ''
      vim.o.number = true
      vim.o.relativenumber = true
      -- The homelab console (TERM=linux) only has 16 colors.
      vim.o.termguicolors = vim.env.TERM ~= "linux"
    '';
  };
}
