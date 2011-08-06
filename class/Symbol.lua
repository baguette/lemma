---
-- Get the Symbol represented by str
---

do

local function __eq(a, b)
	return (type(a) == type(b)) and (tostring(a) == tostring(b))
end

local function __tostring(e)
	return e:string()
end

local t = {}
local mt = {
	class = 'Symbol',
	implements = {},
	__index = t,
	__tostring = __tostring,
	__eq = __eq
}

function Symbol(str)
	local o = {}
	function o:string()
		return str
	end
	setmetatable(o, mt)
	return o
end

end
