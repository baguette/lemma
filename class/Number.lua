---
-- Represent numbers at compile time (to avoid loss of precision).
---

do

local function __eq(a, b)
	return (type(a) == type(b)) and (tostring(a) == tostring(b))
end

local function __tostring(e)
	return 'Number'
end

local t = {}
local mt = {
	class = 'Number',
	implements = {},
	__index = t,
	__tostring = __tostring,
	__eq = __eq
}

Number = function(n)
	if type(n) ~= 'string' then
		return Error('Number objects serve to wrap numbers (as strings) at'..
		             'compile time. (Got '..type(n)..')')
	end
	
	local o = { str = n }
	setmetatable(o, mt)
	return o
end

function t:string()
	return self.str
end

end
