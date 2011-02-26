---
-- A buffered stream of characters from a file source f.
---

require '../interface/Stream'

function FileStream(f)
	local buffer = {}
	local lines = 1
	
	local t = {
		get = function(self)
			local c
			if #buffer > 0 then
				c = table.remove(buffer)
			else
				c = f:read(1)
			end
			if c == '\n' or c == '\r' then
				lines = lines + 1
			end
			return c
		end,
		unget = function(self, c)
			if c == '\n' or c == '\r' then
				lines = lines - 1
			end
			table.insert(buffer, c)
		end,
		source = function(self) return f end,
		lines = function(self) return lines end,
		close = function(self) return self:source():close() end
	}

	local mt = {
		class = 'FileStream',
		implements = { Stream },
		__index = t
	}
	
	local o = {}
	setmetatable(o, mt)
	
	return o
end
