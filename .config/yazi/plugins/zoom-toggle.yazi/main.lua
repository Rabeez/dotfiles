--- @since 25.2.7

local toggle = ya.sync(function(st)
	if not st.zoomed then
		st.old_ratio = { rt.mgr.ratio.parent, rt.mgr.ratio.current, rt.mgr.ratio.preview }
		rt.mgr.ratio = { 0, 1, 9999 }
		st.zoomed = true
	else
		rt.mgr.ratio = st.old_ratio
		st.zoomed = false
	end
	ya.emit("app:resize", {})
	return st.zoomed
end)

local get_hovered = ya.sync(function()
	local h = cx.active.current.hovered
	if h then
		return { url = h.url, path = h.url }
	end
end)

local function is_pdf(url)
	local s = tostring(url):lower()
	return s:match("%.pdf$") ~= nil
end

local function render_pdf_full(url)
	local area = ui.area("preview")
	if not area or area.w == 0 or area.h == 0 then return false end

	local max_w = rt.preview.max_width or 1600
	local max_h = rt.preview.max_height or 1600

	-- Render PDF page 1 at high DPI with pdftoppm, then resize
	local tmp_prefix = os.tmpname()
	local output = Command("pdftoppm"):arg({
		"-png",
		"-f", "1", "-l", "1",
		"-scale-to", tostring(max_h),
		tostring(url),
		tmp_prefix,
	}):output()

	-- pdftoppm outputs to <prefix>-01.png or <prefix>-1.png
	local tmp_img = tmp_prefix .. "-01.png"
	local f = io.open(tmp_img, "r")
	if not f then
		tmp_img = tmp_prefix .. "-1.png"
		f = io.open(tmp_img, "r")
	end
	if not f then
		-- Fallback: try magick for PDF rendering
		tmp_img = tmp_prefix .. ".jpg"
		output = Command("magick"):arg({
			tostring(url) .. "[0]",
			"-resize", string.format("%dx%d", max_w, max_h),
			"-quality", tostring(rt.preview.image_quality or 75),
			string.format("JPG:%s", tmp_img),
		}):output()
		if not output or not output.status.success then
			return false
		end
	else
		f:close()
	end

	ya.image_show(Url(tmp_img), area)
	return true
end

local function render_image_full(url)
	local area = ui.area("preview")
	if not area or area.w == 0 or area.h == 0 then return false end

	local info = ya.image_info(url)
	if not info then return false end

	-- Resize to fill the available area
	local max_w = rt.preview.max_width or 1600
	local max_h = rt.preview.max_height or 1600

	local scale = math.min(max_w / info.w, max_h / info.h)
	local new_w = math.floor(info.w * scale)
	local new_h = math.floor(info.h * scale)

	local tmp = os.tmpname()
	local output, err = Command("magick"):arg({
		tostring(url),
		"-auto-orient", "-strip",
		"-resize", string.format("%dx%d", new_w, new_h),
		"-quality", tostring(rt.preview.image_quality or 75),
		string.format("JPG:%s", tmp),
	}):output()

	if not output or not output.status.success then
		return false
	end

	ya.image_show(Url(tmp), area)
	return true
end

local force_peek = ya.sync(function()
	local h = cx.active.current.hovered
	if h then
		ya.emit("peek", { 0, only_if = h.url, force = true })
	end
end)

return {
	entry = function()
		local zoomed = toggle()
		ya.sleep(0.15)

		if zoomed then
			local h = get_hovered()
			if h then
				if is_pdf(h.url) then
					if not render_pdf_full(h.url) then
						force_peek()
					end
				elseif not render_image_full(h.url) then
					force_peek()
				end
			end
		else
			force_peek()
		end
	end,
}
