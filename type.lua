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

function implements(t, class)
	local mt = getmetatable(t)
	local val = false
	
	if not mt.implements then
		return false
	end
	
	for i, v in ipairs(mt.implements) do
		if v == class then
			val = true
		end
	end
	
	return val
end
