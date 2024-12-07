return {
	{
		"robitx/gp.nvim",
		config = function()
			local gp_additional_prompt = [[
			\nThe user is a programmer and data scientist and prefers terminal-based solutions, ideally using builtin or open-source software solutions. 
Be brief and to-the-point. Avoid repeating information or examples you have already provided previously in conversations. 
Bullet point lists are preferred over multiple paragraphs. Do not provide steps and intermediate explanations unless asked for specifically.
			]]
			-- For customization, refer to Install > Configuration in the Documentation/Readme
			local conf = {
				-- secrets can be strings or tables with command and arguments
				-- secret = { "cat", "path_to/openai_api_key" },
				-- secret = { "bw", "get", "password", "OPENAI_API_KEY" },
				-- secret : "sk-...",
				-- secret = os.getenv("env_name.."),
				-- NOTE: The `cat` approach wasn't working for some reason
				-- openai_api_key = { "cat", "$HOME/dotfiles/Secrets/openai_api_key" },
				openai_api_key = os.getenv("OPENAI_API_KEY_PRO"),
				chat_user_prefix = "󰭻 :",
				chat_assistant_prefix = { " :", "[{{agent}}]" },

				-- use prompt buftype for chats (:h prompt-buffer)
				-- NOTE: Prompt buftype works great as an interface
				-- except that it's readonly and causes issues with saving chat history etc
				chat_prompt_buf_type = false,

				-- how to display GpChatToggle or GpContext
				---@type "popup" | "split" | "vsplit" | "tabnew"
				toggle_target = "popup",

				-- styling for chatfinder
				---@type "single" | "double" | "rounded" | "solid" | "shadow" | "none"
				style_chat_finder_border = "rounded",

				-- styling for popup
				---@type "single" | "double" | "rounded" | "solid" | "shadow" | "none"
				style_popup_border = "rounded",
				agents = {
					{
						name = "ChatGPT4o",
						chat = true,
						command = false,
						-- string with model name or table with model name and parameters
						model = { model = "gpt-4o", temperature = 1.1, top_p = 1 },
						-- system prompt (use this to specify the persona/role of the AI)
						system_prompt = require("gp.defaults").chat_system_prompt .. gp_additional_prompt,
					},
				},
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
