local M = {}

function M:peek(job)
	local child = Command("exiftool")
		:arg({
			"-s",
			"-G",
			tostring(job.file.url),
		})
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		return ya.preview_widget(job, { ui.Text("exiftool not found"):area(job.area) })
	end

	local limit = job.area.h
	local i, lines = 0, ""
	local skipped = 0
	repeat
		local next, event = child:read_line()
		if event ~= 0 then
			break
		end

		if skipped < job.skip then
			skipped = skipped + 1
		else
			i = i + 1
			lines = lines .. next
		end
	until i >= limit

	child:start_kill()
	if job.skip > 0 and i < limit then
		ya.emit("peek", { math.max(0, job.skip - (limit - i)), only_if = job.file.url, upper_bound = true })
	else
		ya.preview_widget(job, { ui.Text(lines):area(job.area) })
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
