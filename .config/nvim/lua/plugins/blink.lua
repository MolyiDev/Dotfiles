return { -- Autocompletion
	"saghen/blink.cmp",
	dependencies = { "saghen/blink.lib" },
	event = "VimEnter",
	config = function()
		require("blink.cmp").setup({
			keymap = {
				preset = "super-tab",

				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-h>"] = { "hide" },
				["<C-y>"] = { "select_and_accept" },
				["<C-e>"] = { "cancel" },

				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback_to_mappings" },
				["<C-j>"] = { "select_next", "fallback_to_mappings" },

				["<C-u>"] = { "scroll_documentation_up", "fallback" },
				["<C-d>"] = { "scroll_documentation_down", "fallback" },

				["<Tab>"] = { "snippet_forward", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "fallback" },
			},

			cmdline = {
				keymap = {
					preset = "none",

					["<Tab>"] = { "show", "select_next" },
					["<S-Tab>"] = { "show", "select_prev" },

					["<C-space>"] = { "show", "show_documentation", "hide_documentation" },

					["<C-u>"] = { "scroll_documentation_up", "fallback" },
					["<C-d>"] = { "scroll_documentation_down", "fallback" },

					["<Up>"] = { "select_prev", "fallback" },
					["<Down>"] = { "select_next", "fallback" },
					["<C-k>"] = { "select_prev", "fallback_to_mappings" },
					["<C-j>"] = { "select_next", "fallback_to_mappings" },

					["<C-h>"] = { "hide" },
					["<C-y>"] = { "select_and_accept" },
					["<C-e>"] = { "cancel" },
					["<CR>"] = { "accept_and_enter", "fallback" },
				},
				completion = {
					menu = { auto_show = false },
					ghost_text = { enabled = true },
				},
			},

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned

				nerd_font_variant = "mono",
			},

			completion = {
				-- By default, you may press `<c-space>` to show the documentation.
				-- Optionally, set `auto_show = true` to show the documentation after a delay.
				menu = {
					scrolloff = 2,
					border = "single", -- e.g. "single", "double", "rounded", or nil to use vim.o.winborder
					draw = {
						padding = 1,
						gap = 1,
					},
					winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
					winblend = 0,
				},
				documentation = {
					window = {
						border = "single", -- documentation float
						winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
					},
					auto_show = true,
					auto_show_delay_ms = 0,
					treesitter_highlighting = true,
				},
				list = {
					selection = {
						auto_insert = false,
					},
				},
			},

			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				providers = {
					lsp = { score_offset = 100 },
					snippets = { score_offset = 9 },
					path = { score_offset = 8 },
					buffer = { score_offset = 8 },
				},
			},

			-- Blink.cmp includes an optional, recommended rust fuzzy matcher,
			-- which automatically downloads a prebuilt binary when enabled.
			--
			-- By default, we use the Lua implementation instead, but you may enable
			-- the rust implementation via `'prefer_rust_with_warning'`
			--
			-- See :h blink-cmp-config-fuzzy for more information
			fuzzy = { implementation = "lua" },

			-- Shows a signature help window while you type arguments for a function
			signature = { enabled = true, window = { border = "single" } },
		})

		vim.api.nvim_set_hl(0, "BlinkCmpScrollBarThumb", { fg = "#ff8800", bg = "#333333" })
		vim.api.nvim_set_hl(0, "BlinkCmpScrollBarGutter", { fg = "#777777", bg = "#222222" })
	end,
}
