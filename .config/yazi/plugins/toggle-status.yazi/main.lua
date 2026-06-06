--- @since 25.2.7
--- @sync entry

local function setup(st)
	st.hidden = true
	st._old_redraw = Status.redraw
	st._old_layout = Tab.layout

	Status.redraw = function() return {} end
	Tab.layout = function(self, ...)
		self._area = ui.Rect { x = self._area.x, y = self._area.y, w = self._area.w, h = self._area.h + 1 }
		return st._old_layout(self, ...)
	end
end

local function entry(st)
	if st.hidden then
		Status.redraw = st._old_redraw
		Tab.layout = st._old_layout
	else
		Status.redraw = function() return {} end
		Tab.layout = function(self, ...)
			self._area = ui.Rect { x = self._area.x, y = self._area.y, w = self._area.w, h = self._area.h + 1 }
			return st._old_layout(self, ...)
		end
	end
	st.hidden = not st.hidden
	ya.emit("app:resize", {})
end

return { setup = setup, entry = entry }
