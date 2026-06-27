-- Highlight, edit, and navigate code
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
	},
	config = function()
		require("nvim-treesitter").setup()

		local ensure_installed = {
			"lua",
			"luau",
			"javascript",
			"typescript",
			"regex",
			"toml",
			"json",
			"gitignore",
			"yaml",
			"markdown",
			"markdown_inline",
			"mermaid",
			"bash",
			"tsx",
			"css",
			"html",
			"xml",
		}

		local installed = require("nvim-treesitter.config").get_installed("parsers")
		local to_install = vim.tbl_filter(function(p)
			return not vim.tbl_contains(installed, p)
		end, ensure_installed)
		if #to_install > 0 then
			require("nvim-treesitter").install(to_install)
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("user-ts-enable", { clear = true }),
			callback = function(ev)
				if pcall(vim.treesitter.start, ev.buf) then
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		require("nvim-treesitter-textobjects").setup({
			select = { lookahead = true },
			move = { set_jumps = true },
		})

		local sel = require("nvim-treesitter-textobjects.select").select_textobject
		local mv = require("nvim-treesitter-textobjects.move")
		local swap = require("nvim-treesitter-textobjects.swap")
		local map = vim.keymap.set

		map({ "x", "o" }, "aa", function() sel("@parameter.outer", "textobjects") end, { desc = "outer parameter" })
		map({ "x", "o" }, "ia", function() sel("@parameter.inner", "textobjects") end, { desc = "inner parameter" })
		map({ "x", "o" }, "af", function() sel("@function.outer", "textobjects") end, { desc = "outer function" })
		map({ "x", "o" }, "if", function() sel("@function.inner", "textobjects") end, { desc = "inner function" })
		map({ "x", "o" }, "ac", function() sel("@class.outer", "textobjects") end, { desc = "outer class" })
		map({ "x", "o" }, "ic", function() sel("@class.inner", "textobjects") end, { desc = "inner class" })

		map({ "n", "x", "o" }, "]m", function() mv.goto_next_start("@function.outer", "textobjects") end, { desc = "next function start" })
		map({ "n", "x", "o" }, "]]", function() mv.goto_next_start("@class.outer", "textobjects") end, { desc = "next class start" })
		map({ "n", "x", "o" }, "]M", function() mv.goto_next_end("@function.outer", "textobjects") end, { desc = "next function end" })
		map({ "n", "x", "o" }, "][", function() mv.goto_next_end("@class.outer", "textobjects") end, { desc = "next class end" })
		map({ "n", "x", "o" }, "[m", function() mv.goto_previous_start("@function.outer", "textobjects") end, { desc = "prev function start" })
		map({ "n", "x", "o" }, "[[", function() mv.goto_previous_start("@class.outer", "textobjects") end, { desc = "prev class start" })
		map({ "n", "x", "o" }, "[M", function() mv.goto_previous_end("@function.outer", "textobjects") end, { desc = "prev function end" })
		map({ "n", "x", "o" }, "[]", function() mv.goto_previous_end("@class.outer", "textobjects") end, { desc = "prev class end" })

		map("n", "<leader>a", function() swap.swap_next("@parameter.inner") end, { desc = "swap next parameter" })
		map("n", "<leader>A", function() swap.swap_previous("@parameter.inner") end, { desc = "swap prev parameter" })
	end,
}
