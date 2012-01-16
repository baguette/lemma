require 'class/List'
require 'class/Vector'

do

local function __tostring(e)
	return 'iter:'..tostring(e.f)..','..tostring(e.s)..','..tostring(e.a)
end

local function __eq(self, e)
	return (rawequal(self.f, e.f)
	    and rawequal(self.s, e.s)
	    and rawequal(self.a, e.a))
end

local t = {}
local mt = {
	class = 'Iter',
	implements = { Seq = true },
	__index = t,
	__tostring = __tostring,
	__eq = __eq
}

function Iter(f, s, a)
	local o = { f = f, s = s, a = a }
	setmetatable(o, mt)
	return o
end

function t:first()
	local val = { self.f(self.s, self.a) }
	if val[1] then
		return Vectorize(val)
	else
		return nil
	end
end

function t:rest()
	local val = { self.f(self.s, self.a) }
	if (val[1]) then
		return Iter(self.f, self.s, val[1])
	else
		return nil
	end
end

t['empty?'] = function(self)
	return false
end

function t:seq()
	return List()
end

end
