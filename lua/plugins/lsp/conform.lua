local slow_format_filetypes = {}

local prettier = {
	require_cwd = false,
	args = function(_, ctx)
		local prettier_roots = {
			".prettierrc",
			".prettierrc.json",
			".prettierrc.yaml",
			".prettierrc.toml",
			".prettierrc.js",
			".prettierrc.mjs",
			".prettierrc.cjs",
			"prettier.config.js",
			"prettier.config.mjs",
			"prettier.config.cjs",
		}

		local args = {
			"--tab-width",
			"4",
			"--no-semi",
			"--no-bracket-spacing",
			"--single-quote",
			"--stdin-filepath",
			"$FILENAME",
		}

		local disableGlobalPrettierConfig = os.getenv("DISABLE_GLOBAL_PRETTIER_CONFIG")

		local localPrettierConfig = vim.fs.find(prettier_roots, {
			upward = true,
			type = "file",
		})[1]

		local globalPrettierConfig = vim.fs.find(prettier_roots, {
			---@diagnostic disable-next-line: assign-type-mismatch
			path = vim.fn.stdpath("config"),
			type = "file",
		})[1]

		local hasTailwindPrettierPlugin = vim.fs.find("node_modules/prettier-plugin-tailwindcss", {
			upward = true,
			path = ctx.dirname,
			type = "directory",
		})[1]

		if localPrettierConfig then
			args = { "--config", localPrettierConfig, "$FILENAME" }
		elseif globalPrettierConfig and not disableGlobalPrettierConfig then
			args = { "--config", globalPrettierConfig, "$FILENAME" }
		end

		if hasTailwindPrettierPlugin then
			vim.list_extend(args, { "--plugin", "prettier-plugin-tailwindcss" })
		end

		return args
	end,
}

return {
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"jay-babu/mason-null-ls.nvim",
		},
		config = function()
			local mason_null_ls = require("mason-null-ls")

			mason_null_ls.setup({
				ensure_installed = {
					"prettier",
					"black",
					"stylua",
					"beautysh",
					"php_cs_fixer",
					"clang-format",
					"yamlfmt",
				},
				automatic_installation = true,
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>fr",
				function()
					require("conform").format({
						format_after_save = {
							lsp_fallback = true,
						},
					})
				end,
			},
		},
		opts = {
			quiet = true,
			formatters_by_ft = {
				c = { "clang-format" },
				cpp = { "clang-format" },

				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				php = { "php_cs_fixer" },
				python = { "black" },
				lua = { "stylua" },

				sh = { "beautysh" },
				bash = { "beautysh" },
				zsh = { "beautysh" },

				html = { "prettier" },
				markdown = { "prettier" },
				yaml = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
			},

			formatters = {
				prettier = prettier,
			},

			format_on_save = function(bufnr)
				local bufname = vim.api.nvim_buf_get_name(bufnr)

				if bufname:match("/node_modules/") then
					return
				end

				if slow_format_filetypes[vim.bo[bufnr].filetype] then
					return
				end

				local function on_format(err)
					if err and err:match("timeout$") then
						slow_format_filetypes[vim.bo[bufnr].filetype] = true
					end
				end

				return { timeout_ms = 200, lsp_format = "fallback" }, on_format
			end,

			format_after_save = function(bufnr)
				if not slow_format_filetypes[vim.bo[bufnr].filetype] then
					return
				end
				return { lsp_format = "fallback" }
			end,
		},
	},
}
