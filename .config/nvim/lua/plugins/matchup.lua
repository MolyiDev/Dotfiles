return {
	"andymass/vim-matchup",
	init = function()
		vim.g.matchup_matchparen_offscreen = { method = "popup" }
		vim.g.matchup_treesitter_enabled = true
		vim.g.matchup_treesitter_stopline = 500
	end,
}
