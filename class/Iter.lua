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
	return 'iter:'..tostring(e.f)
end

local function __eq(self, e)
	return (rawequal(self.f, e.f)
	    and rawequal(self.s, e.s)
	    and rawequal(self.a, e.a)
	    and rawequal(self.buffer.n, e.buffer.n)
	    and rawequal(self.buffer.i, e.buffer.i)
	    and rawequal(self.buffer.s, e.buffer.s))
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
	buffer = {n=0, i=1, s={}}
	
	if buffer.n == 0 then
		local val
		a, val = filter(f(s, a))
		buffer.n = 1
		buffer.s[buffer.n] = val
		if a == nil then
			return List()
		end
	end
	
	local o = { f = f, s = s, a = a, filter = filter, buffer = buffer }
	setmetatable(o, mt)
	return o
end

local function attach(f, s, a, filter, buffer)	
	local o = { f = f, s = s, a = a, filter = filter, buffer = buffer }
	setmetatable(o, mt)
	return o
end

function t:first()
	if self.a ~= nil then
		local new_a, val = self.filter(self.f(self.s, self.a))
		if new_a ~= nil then
			self.buffer.n = self.buffer.n + 1
			self.buffer.s[self.buffer.n] = val
		end
		self.a = new_a
	end
	if self.buffer.i <= self.buffer.n then
		return self.buffer.s[self.buffer.i]
	else
		return Error'something went wrong in Iter'
	end
end

function t:rest()
	if self.a ~= nil then
		local new_a, val = self.filter(self.f(self.s, self.a))
		if new_a ~= nil then
			self.buffer.n = self.buffer.n + 1
			self.buffer.s[self.buffer.n] = val
		end
		self.a = new_a
	end
	return attach(self.f, self.s, self.a, self.filter,
	              { n=self.buffer.n, i=self.buffer.i+1, s=self.buffer.s})
end

function t:cons(a)
	local s = {}
	for i = 1, self.buffer.n do
		s[i] = self.buffer.s[i]
	end
	table.insert(s, self.buffer.i, a)
	return attach(self.f, self.s, self.a, self.filter,
	              { n=self.buffer.n+1, i=self.buffer.i, s=s})
end

t['empty?'] = function(self)
	return (self.a == nil and self.buffer.i > self.buffer.n)
end

function t:seq()
	return List()
end

end
