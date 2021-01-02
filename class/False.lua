---
-- Placeholder for false
---

do

local function __eq(a, b)
	return (lemma.type(a) == lemma.type(b)) and (tostring(a) == tostring(b))
end

local function __tostring(e)
	return 'False'
end

local t = {}
local mt = {
	class = 'False',
	implements = nil,
	__index = t,
	__tostring = __tostring,
	__eq = __eq
}

False = {}

function False:string()
	return 'False'
end

setmetatable(False, mt)

end
