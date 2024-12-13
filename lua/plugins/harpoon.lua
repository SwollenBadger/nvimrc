return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup()

		vim.keymap.set("n", "<S-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)
		vim.keymap.set("n", "<S-s>", function()
			harpoon:list():add()
		end)

		vim.keymap.set("n", "<S-r>", function()
			harpoon:list():select(1)
		end)
		vim.keymap.set("n", "<S-t>", function()
			harpoon:list():select(2)
		end)
		vim.keymap.set("n", "<S-y>", function()
			harpoon:list():select(3)
		end)
		vim.keymap.set("n", "<S-u>", function()
			harpoon:list():select(4)
		end)
	end,
}
