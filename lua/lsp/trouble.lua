return {
	"folke/trouble.nvim",
	opts = {}, -- for default options, refer to the configuration section for custom setup.
	cmd = "Trouble",
	keys = {
		{
			"<leader>tt",
			":Trouble diagnostics toggle<cr>",
			silent = true,
		},
		{
			"]t",
			function()
				require("trouble").next({ skip_groups = true, jump = true })
			end,
		},

		{
			"[t",
			function()
				require("trouble").prev({ skip_groups = true, jump = true })
			end,
		},
	},
}
