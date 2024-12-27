local M = {
	"nvimtools/none-ls.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
}

function M.config()
	local null_ls = require("null-ls")

	-- Configuration for none-ls (null-ls) providing formatting and diagnostics
	null_ls.setup({
		sources = {
			-- Lua formatting using stylua
			null_ls.builtins.formatting.stylua,

			-- Ruby/Rails linting with erb-lint (requires .erb_lint.yml config file)
			null_ls.builtins.diagnostics.erb_lint.with({
				condition = function(utils)
					return utils.root_has_file({ ".erb_lint.yml" })
				end,
			}),

			-- Rubocop auto-correction configuration
			null_ls.builtins.formatting.rubocop.with({
				command = vim.fn.executable("bundle") == 1 and "bundle" or "rubocop",
				args = vim.fn.executable("bundle") == 1 and {
					"exec",
					"rubocop",
					"--auto-correct-all",
					"--force-exclusion",
					"--stdin",
					"$FILENAME",
				} or {
					"--auto-correct-all",
					"--force-exclusion",
					"--stdin",
					"$FILENAME",
				},
				to_stdin = true,
			}),

			-- Ruby code smell detection using reek
			null_ls.builtins.diagnostics.reek,

			-- Python static type checking
			null_ls.builtins.diagnostics.mypy,

			-- Web-related file formatting using prettier
			null_ls.builtins.formatting.prettier.with({
				filetypes = { "html", "json", "yaml", "markdown", "eruby" },
			}),
		},

		-- Format on save with file size check to prevent performance issues
		on_attach = function(client, bufnr)
			if client.supports_method("textDocument/formatting") then
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function()
						-- Skip formatting for files larger than 100KB
						local max_size = 100 * 1024
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
						if ok and stats and stats.size > max_size then
							return
						end

						-- Format using null-ls with a 2 second timeout
						vim.lsp.buf.format({
							async = false,
							timeout_ms = 2000,
							bufnr = bufnr,
							filter = function(client)
								return client.name == "null-ls"
							end,
						})
					end,
				})
			end
		end,

		-- Debug and diagnostic settings
		debug = false, -- Disable debug mode for production
		diagnostics_format = "#{m}", -- Simple message format
		fallback_severity = vim.diagnostic.severity.HINT,
		log_level = "warn", -- Only log warnings and errors
		stdout = false, -- Disable stdout logging
		stderr = false, -- Disable stderr logging
	})

	-- Add keybinding for manual formatting
	vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, {
		desc = "Format file",
		silent = true,
	})

	-- Add diagnostic configuration
	vim.diagnostic.config({
		virtual_text = {
			prefix = "●", -- Use a dot as the prefix
			spacing = 4,
			source = "if_many",
		},
		float = {
			source = "always",
			border = "rounded",
			header = "",
			prefix = "",
		},
		signs = true,
		underline = true,
		update_in_insert = false,
		severity_sort = true,
	})

	-- Add diagnostic signs with distinct colors
	local signs = {
		Error = " ",
		Warn = " ",
		Hint = " ",
		Info = " ",
	}
	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	end
end

return M
