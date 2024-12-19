local M = {
	"nvimtools/none-ls.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
}

function M.config()
	local null_ls = require("null-ls")

	-- Simple configuration focused on core functionality
	null_ls.setup({
		sources = {
			-- Lua formatting
			null_ls.builtins.formatting.stylua,

			-- Ruby/Rails linting and formatting
			null_ls.builtins.diagnostics.erb_lint.with({
				condition = function(utils)
					return utils.root_has_file({ ".erb_lint.yml" })
				end,
			}),

			-- Rubocop with bundler support
			null_ls.builtins.diagnostics.rubocop.with({
				command = "bundle",
				args = vim.fn.executable("bundle") == 1 and {
					"exec",
					"rubocop",
					"--format",
					"json",
					"--force-exclusion",
					"--stdin",
					"$FILENAME",
				} or nil,
				runtime_condition = function()
					return vim.fn.filereadable("Gemfile") == 1
				end,
				stderr = true,
				format = "json",
			}),

			null_ls.builtins.formatting.rubocop.with({
				command = "bundle",
				args = vim.fn.executable("bundle") == 1 and {
					"exec",
					"rubocop",
					"--auto-correct-all",
					"--force-exclusion",
					"--stdin",
					"$FILENAME",
					"--stderr",
				} or nil,
				runtime_condition = function()
					return vim.fn.filereadable("Gemfile") == 1
				end,
				to_stdin = true,
				to_temp_file = true,
			}),

			-- Code smell detection
			null_ls.builtins.diagnostics.reek,

			-- Python type checking
			null_ls.builtins.diagnostics.mypy,

			-- Web formatting
			null_ls.builtins.formatting.prettier.with({
				filetypes = { "html", "json", "yaml", "markdown", "eruby" },
			}),
		},

		-- Format on save with performance optimization
		on_attach = function(client, bufnr)
			if client.supports_method("textDocument/formatting") then
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function()
						-- Skip large files to avoid performance issues
						local max_size = 100 * 1024 -- 100KB
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
						if ok and stats and stats.size > max_size then
							return
						end

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

		-- Minimal debug settings
		debug = false,
		diagnostics_format = "#{m}",
		fallback_severity = vim.diagnostic.severity.HINT,
		log_level = "warn",
		stdout = false,
		stderr = false,
	})

	-- Format keybinding
	vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, {
		desc = "Format file",
		silent = true,
	})
end

return M
