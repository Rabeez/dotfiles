--- @since 25.2.7

local M = {}

function M:peek(job)
	local area = job.area
	if not area or area.w == 0 or area.h == 0 then return end

	local max_w = rt.preview.max_width or 1600
	local max_h = rt.preview.max_height or 1600

	-- Determine which page to render (skip = page number)
	local page = job.skip + 1

	local tmp_prefix = os.tmpname()
	local output = Command("pdftoppm"):arg({
		"-png",
		"-f", tostring(page),
		"-l", tostring(page),
		"-scale-to", tostring(max_h),
		tostring(job.file.url),
		tmp_prefix,
	}):output()

	-- pdftoppm outputs to <prefix>-<pagenum>.png with zero-padded numbers
	local tmp_img
	local candidates = {
		string.format("%s-%02d.png", tmp_prefix, page),
		string.format("%s-%d.png", tmp_prefix, page),
		string.format("%s-%03d.png", tmp_prefix, page),
	}
	for _, path in ipairs(candidates) do
		local f = io.open(path, "r")
		if f then
			f:close()
			tmp_img = path
			break
		end
	end

	if not tmp_img then
		-- Fallback to magick
		tmp_img = tmp_prefix .. ".jpg"
		output = Command("magick"):arg({
			tostring(job.file.url) .. string.format("[%d]", page - 1),
			"-resize", string.format("%dx%d", max_w, max_h),
			"-quality", tostring(rt.preview.image_quality or 75),
			string.format("JPG:%s", tmp_img),
		}):output()

		if not output or not output.status.success then
			ya.preview_widget(job, { ui.Text("Failed to render PDF"):area(area) })
			return
		end
	end

	ya.image_show(Url(tmp_img), area)
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		local step = job.units > 0 and 1 or -1
		local new_skip = math.max(0, cx.active.preview.skip + step)
		ya.emit("peek", {
			new_skip,
			only_if = job.file.url,
			force = true,
		})
	end
end

return M
