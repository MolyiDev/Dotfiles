-- [[ Basic Autocommands ]]

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- A more aggressive way to get lualine and tpipline not render 2 lualines.
vim.opt.laststatus = 0
vim.api.nvim_create_autocmd("OptionSet", {
	group = vim.api.nvim_create_augroup("ForceLastStatusZero", { clear = true }),
	pattern = "laststatus",
	callback = function()
		if vim.opt.laststatus:get() ~= 0 then
			vim.opt.laststatus = 0
		end
	end,
})

-- [[ Install `lazy.nvim` plugin manager ]]

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]

require("lazy").setup({
	require("plugins.obsidian"),
	require("plugins.treesitter"),
	require("plugins.lsp"),
	require("plugins.telescope"),
	require("plugins.blink"),
	require("plugins.smart_splits"),
	-- require("plugins.autopair"),
	-- require("plugins.tabout"),
	require("plugins.conform"),
	require("plugins.fugitive"),
	require("plugins.luau_lsp"),
	require("plugins.project"),
	require("plugins.multicursor"),
	require("plugins.theme"),
	require("plugins.todo_comments"),
	require("plugins.lualine"),
	require("plugins.tpipeline"),
	require("plugins.matchup"),
	require("plugins.surround"),
	require("plugins.indent"),
	require("plugins.trouble"),
	require("plugins.gitsigns"),
	require("plugins.linter"),
	require("plugins.noice"),
	require("plugins.yazi"),
	require("plugins.markdown-preview"),
})

-- [[ Requires ]]
require("keymaps")
require("options")
