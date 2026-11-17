return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			nix = { "alejandra" },
			python = { "ruff_format", "ruff_organize_imports" },
		},
	},
}
