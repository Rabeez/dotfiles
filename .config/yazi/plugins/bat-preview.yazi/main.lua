local M = {}

function M:peek(job)
	local child = Command("bat")
		:arg({
			"--color=always",
			"--style=numbers,changes",
			"--line-range",
			string.format("%d:", job.skip + 1),
			"--terminal-width",
			tostring(job.area.w),
			tostring(job.file.url),
		})
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		return require("code"):peek(job)
	end

	local limit = job.area.h
	local i, lines = 0, ""
	repeat
		local next, event = child:read_line()
		if event == 1 then
			return require("code"):peek(job)
		elseif event ~= 0 then
			break
		end

		i = i + 1
		lines = lines .. next
	until i >= limit

	child:start_kill()
	if job.skip > 0 and i < limit then
		ya.emit("peek", { math.max(0, job.skip - (limit - i)), only_if = job.file.url, upper_bound = true })
	else
		ya.preview_widget(job, { ui.Text.parse(lines):area(job.area) })
	end
end

function M:seek(job)
	local h = cx.active.current.hovered
	if not h or h.url ~= job.file.url then
		return
	end
	local step = math.floor(job.units * job.area.h / 10)
	ya.emit("peek", {
		math.max(0, cx.active.preview.skip + step),
		only_if = job.file.url,
		force = true,
	})
end

return M
