
require '../interface/Seq'
require '../interface/Reversible'

do

local function __tostring(e)
	local str = {}
	
	for i = 1, e:length() do
		table.insert(str, tostring(e[i]))
		table.insert(str, ' ')
	end
	
	table.remove(str)
	return '['..table.concat(str)..']'
end

local function __eq(self, e)
	if self:length() ~= e:length() then
		return false
	end
	for i = 1, self:length() do
		if self[i] ~= e[i] then
			return false
		end
	end
	return true
end

local function __call(t, k, v)
	if v then
		t[k] = v
		return v
	else
		return t[k]
	end
end

local t = {}

function t:length()
	return lemma['get-meta'](self, 'length') or 0
end

local mt = {
	class = 'Vector',
	implements = { Seq = true, Reversible = true },
	__index = t,
	__tostring = __tostring,
	__call = __call,
	__eq = __eq,
	__len = t.length
}

function t:cons(...)
	local new = Vector()
	local n = select('#', ...)
	local args = {...}
	
	for i = 1, n do
		new[i] = args[i]
	end
	
	for i = 1, self:length() do
		new[n+i] = self[i]
	end
	
	lemma['assoc-meta'](new, 'length', self:length() + n)
	return new
end

function t:first()
	return self[1]
end

function t:rest()
	local new = Vector()
	
	for i = 2, self:length() do
		new[i-1] = self[i]
	end
	
	lemma['assoc-meta'](new, 'length', self:length()-1)
	
	return new
end

t['empty?'] = function(self)
	return (self:length() == 0)
end

function t:reverse()
	local new = {}
	
	for i = self:length(), 1, -1 do
		new[i] = self[self:length()-i+1]
	end
	
	return Vectorize(new, self:length())
end

-- TODO: This should preserve any potential metatable of o, if possible
function Vectorize(o, n)
	lemma['assoc-meta'](o, 'length', n or #o)
	setmetatable(o, mt)
	return o
end

function Vector(...)
	local n = select('#', ...)
	local o = {...}
	return Vectorize(o, n)
end

function t:seq()
	return Seq.lib.map(function(x) return x end, self)
end

end
