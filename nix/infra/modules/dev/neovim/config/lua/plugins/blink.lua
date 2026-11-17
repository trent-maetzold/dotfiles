local blink = {
	"saghen/blink.cmp",
	-- lazyvim-nix marks Nix-managed plugins `dev = true`, which puts the store
	-- copy on the runtimepath. the rust fuzzy binary is resolved relative to
	-- the loaded Lua file, so it then looks inside the read-only store and
	-- never finds target/release/libblink_cmp_fuzzy.so. load from lazy's own
	-- checkout instead, where the prebuilt binary actually lives.
	dev = false,
	dependencies = {"fang2hou/blink-copilot"},
	opts = {
		completion = {
			ghost_text = { enabled = false },
			list = {
				selection = { preselect = false },
			},
		},
		fuzzy = {
			implementation = "prefer_rust_with_warning",
		},
		sources = {
			default = { "copilot" },
			providers = {
				copilot = {
					name = "copilot",
					module = "blink-copilot",
					async = true,
					score_offset = 100,
				},
			},
		},
	},
}

return {blink}
