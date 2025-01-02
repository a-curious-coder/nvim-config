return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		opts = {
			auto_install = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local capabilities = require('cmp_nvim_lsp').default_capabilities()

			local lspconfig = require("lspconfig")

			-- Function to notify when LSP attaches
			local on_attach = function(client, bufnr)
				vim.notify(string.format("LSP %s is ready!", client.name), vim.log.levels.INFO)
			end

			-- Setup LSP servers
			lspconfig.html.setup({
				capabilities = capabilities,
				on_attach = on_attach
			})
			lspconfig.jsonls.setup({
				capabilities = capabilities,
				on_attach = on_attach
			})
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach
			})
			lspconfig.pyright.setup({
				capabilities = capabilities,
				on_attach = on_attach
			})
			lspconfig.pylsp.setup({
				capabilities = capabilities,
				on_attach = on_attach
			})
			lspconfig.ruby_lsp.setup({
				capabilities = capabilities,
				cmd = { "ruby-lsp" },
				on_attach = on_attach,
				settings = {
					rubocop = {
						enable = true,  -- Enable RuboCop integration
						lint = true,    -- Enable linting
						format = true   -- Enable formatting
					}
				}
			})
			lspconfig.tailwindcss.setup({
				capabilities = capabilities,
				on_attach = on_attach
			})

			-- Keymaps
			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
			vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
		end,
	},
}
