---
-- Macros are functions whose arguments are not evaluated prior to
-- applying them.  Their value after application is then evaluated.
---

do

local function __eq(a, b)
	return (a.func == b.func)
end

local function __tostring(e)
	return 'macro: '..tostring(e.func)
end

local function __call(e, ...)
	return e.func(...)
end

local t = {}
local mt = {
	class = 'Macro',
	implements = {},	-- should implement a Callable interface later?
	__index = t,
	__eq = __eq,
	__tostring = __tostring,
	__call = __call
}

function Macro(f)
	local o = {}
	o.func = f
	setmetatable(o, mt)
	return o
end

end
