return {
	{
		"robitx/gp.nvim",
		config = function()
			-- For customization, refer to Install > Configuration in the Documentation/Readme
			local conf = {
				-- secrets can be strings or tables with command and arguments
				-- secret = { "cat", "path_to/openai_api_key" },
				-- secret = { "bw", "get", "password", "OPENAI_API_KEY" },
				-- secret : "sk-...",
				-- secret = os.getenv("env_name.."),
				-- NOTE: The `cat` approach wasn't working for some reason
				-- openai_api_key = { "cat", "$HOME/dotfiles/Secrets/openai_api_key" },
				chat_user_prefix = "󰭻 :",
				chat_assistant_prefix = { " :", "[{{agent}}]" },

				-- use prompt buftype for chats (:h prompt-buffer)
				chat_prompt_buf_type = true,

				-- how to display GpChatToggle or GpContext
				---@type "popup" | "split" | "vsplit" | "tabnew"
				toggle_target = "popup",

				-- styling for chatfinder
				---@type "single" | "double" | "rounded" | "solid" | "shadow" | "none"
				style_chat_finder_border = "rounded",

				-- styling for popup
				---@type "single" | "double" | "rounded" | "solid" | "shadow" | "none"
				style_popup_border = "rounded",
			}
			require("gp").setup(conf)

			-- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
			vim.keymap.set("n", "<leader>at", "<cmd>GpChatToggle popup<CR>", { desc = "[A]I: [T]oggle chat popup" })
			vim.keymap.set("n", "<leader>an", "<cmd>GpChatNew popup<CR>", { desc = "[A]I: [N]ew chat popup" })
			vim.keymap.set("n", "<leader>as", "<cmd>GpStop<CR>", { desc = "[A]I: [S]top all processing" })
			vim.keymap.set("n", "<leader>fa", "<cmd>GpChatFinder<CR>", { desc = "Telescope: [F]ind [A]I chat" })
			vim.keymap.set("n", "<leader>ag", "<cmd>GpChatRespond<CR>", { desc = "[A]I: [G]enerate response" })
			vim.keymap.set("n", "<leader>ad", "<cmd>GpChatDelete<CR>", { desc = "[A]I: [D]elete current chat" })
		end,
	},
}
