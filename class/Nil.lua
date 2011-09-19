---
-- Placeholder for nil
---

do

local function __eq(a, b)
	return (type(a) == type(b)) and (tostring(a) == tostring(b))
end

local function __tostring(e)
	return 'Nil'
end

local t = {}
local mt = {
	class = 'Nil',
	implements = nil,
	__index = t,
	__tostring = __tostring,
	__eq = __eq
}

Nil = {}

function Nil:string()
	return 'Nil'
end

setmetatable(Nil, mt)

end
