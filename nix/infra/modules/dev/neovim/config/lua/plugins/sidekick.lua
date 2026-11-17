return {
	{
		"folke/sidekick.nvim",
		opts = {
			nes = { enabled = false },
			cli = {
				mux = {
					backend = "tmux",
					enabled = true,
				},
			},
		},
		keys = {
			{
				"<leader>ai",
				function()
					require("sidekick.cli").toggle({ name = "pi", focus = true })
				end,
				desc = "Sidekick Toggle pi",
			},
		},
	},
}
