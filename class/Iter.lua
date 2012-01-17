---
-- Essentially a lazy seq that works in a manner compatible with
-- Lua's iterator functions (so that the usual seq functions can
-- be used in place of Lua's generic for).
--
-- TODO: Some of this could use some refactoring... but I'm le tired.
---

require 'class/List'
require 'class/Vector'

do

local function __tostring(e)
	return tostring(e:seq())
end

local function __eq(self, e)
	return (self.f == e.f
	    and self.s == e.s
	    and self.a == e.a
	    and self.filter == e.filter
	    and self.head == e.head)
end

local t = {}
local mt = {
	class = 'Iter',
	implements = { Seq = true },
	__index = t,
	__tostring = __tostring,
	__eq = __eq
}

-- A default filter that's useful for interfacing with Lua iterator functions.
-- Other filters can be useful for other types of lazy sequences.
-- A filter returns two values: a new "iterator variable" value which is the
-- control variable that is used by generic for, and a value to treat as
-- the result of iteration (they can be the same).
local function package(...)
	local val = Vector(...)
	
	if val:length() > 1 then
		return val[1], val
	else
		return val[1], val[1]
	end
end

function Iter(f, s, a, filter)
	filter = filter or package
	
	local val
	a, val = filter(f(s, a))
	if a == nil then
		return List()
	end
	
	local o = { f = f, s = s, a = a, filter = filter, head = val }
	setmetatable(o, mt)
	return o
end

function t:first()
	return self.head
end

function t:rest()
	if self.tail ~= nil then
		return self.tail
	end
	return Iter(self.f, self.s, self.a, self.filter)
end

function t:cons(a)
	local o = {head = a, tail = self}
	setmetatable(o, mt)
	return o
end

-- Iter will return an empty List when there are no further values.
t['empty?'] = function(self)
	return false
end

---
-- Be careful when using these! Use on an infite list will never terminate.
---
function t:seq()
	return List(Seq.lib.unpack(self))
end

function t:length()
	return self:seq():length()
end

function t:reverse()
	return self:seq():reverse()
end

end
