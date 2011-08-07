---
-- Fexprs are functions whose arguments are not evaluated prior to
-- applying them.  If they want to evaluate their arguments, they do
-- so as needed.
--
-- The special forms are implemented with Fexprs.
---

do

local function __eq(a, b)
	return (a.func == b.func)
end

local function __tostring(e)
	return 'fexpr: '..tostring(e.func)
end

local function __call(e, ...)
	return e.func(...)
end

local t = {}
local mt = {
	class = 'Fexpr',
	implements = {},	-- should implement a Callable interface later?
	__index = t,
	__eq = __eq,
	__tostring = __tostring,
	__call = __call
}

function Fexpr(f)
	local o = {}
	o.func = f
	setmetatable(o, mt)
	return o
end

end
