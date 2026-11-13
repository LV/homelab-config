{ inputs, ... }:

{
  programs.neovim.initLua = ''
    -- Explicit "+ / "* registers only: ordinary yanks/deletes stay local to Neovim.
    -- Paste reads our saved file, never an OSC 52 clipboard query to the client.
    local function copy_clipboard(lines)
      local text = table.concat(lines, "\n"):gsub("\n+$", "")
      local output = vim.fn.system({ "${inputs.dotfiles}/bin/copy" }, text)
      if vim.v.shell_error ~= 0 then
        error("copy failed: " .. output)
      end
      -- Neovim jobs have no controlling terminal. Send OSC 52 through its UI,
      -- while the command above handles the shared local save.
      local term = vim.env.TERM or ""
      if term ~= "linux" and term ~= "dumb" and term ~= "" then
        require("vim.ui.clipboard.osc52").copy("+")(vim.split(text, "\n", { plain = true }))
      end
    end

    vim.g.clipboard = {
      name = "OSC 52 with local fallback",
      copy = {
        ["+"] = copy_clipboard,
        ["*"] = copy_clipboard,
      },
      paste = {
        ["+"] = { "${inputs.dotfiles}/bin/pasta" },
        ["*"] = { "${inputs.dotfiles}/bin/pasta" },
      },
      cache_enabled = 0,
    }
  '';
}
