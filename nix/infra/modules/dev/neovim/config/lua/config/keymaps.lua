-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- jk escape: insert mode everywhere
vim.keymap.set("i", "jk", "<Esc>", { desc = "jk escape" })

-- terminal mode: jk → normal mode, buffer-local and never in lazygit.
-- A multi-key `t` mapping makes nvim swallow the first key until the mapping
-- resolves at `timeoutlen` (1s by default), which lands as a full second of
-- lag on every j/k press in lazygit. Other terminals keep the mapping.
local jk_escape_group = vim.api.nvim_create_augroup("jk_escape", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
  group = jk_escape_group,
  callback = function(args)
    local buf = args.buf
    local program = vim.b[buf].terminal_program_name
      or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
    if program:find("lazygit") then
      return
    end
    vim.keymap.set("t", "jk", "<C-\\><C-n>", { buffer = buf, desc = "jk escape (terminal)" })
  end,
})

-- sops edit the current file in a terminal, unlocking rbw (the master key) first.
vim.keymap.set("n", "<leader>fS", function()
  Snacks.terminal({ "sh", "-c", 'rbw unlock && sops edit "$1"', "sops", vim.fn.expand("%") })
end, { desc = "Edit with sops" })
