---
-- Custom type tracking
---

type = (function()
	local xtype = type
	return function(o)
		local t = xtype(o)
		
		if t == 'table' then
			local mt = getmetatable(o)
			local class = mt and mt.class
			
			if class then
				return class
			end
		end
		
		return t
	end
end)()
