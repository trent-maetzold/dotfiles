local nix = require("config.nixpaths")

return {
	"folke/snacks.nvim",
	opts = {
		picker = {
			db = {
				sqlite3_path = nix.sqlite3_lib,
			},
		},
	},
}
