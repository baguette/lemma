
require '../interface/Seq'
require '../interface/Reversible'

do

local function __tostring(e)
	local str = {}
	
	for _, v in ipairs(e) do
		table.insert(str, tostring(v))
		table.insert(str, ' ')
	end
	
	table.remove(str)
	return '['..table.concat(str)..']'
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
local mt = {
	class = 'Vector',
	implements = { 'Seq', 'Reversible' },
	__index = t,
	__tostring = __tostring,
	__call = __call
}

function t:cons(...)
	local new = Vector()
	local args = {...}
	
	for i = 1, #args do
		table.insert(new, args[i])
	end
	
	for i = 1, #self do
		table.insert(new, self[i])
	end
	
	lemma['assoc-meta'](new, 'length', self:length() + #args)
	return new
end

function t:length()
	return lemma['get-meta'](self, 'length') or 0
end

function t:first()
	return self[1]
end

function t:rest()
	local new = Vector()
	
	for i = 2, #self do
		table.insert(new, self[i])
	end
	
	lemma['assoc-meta'](new, 'length', #new)
	
	return new
end

t['empty?'] = function(self)
	return (#self == 0)
end

function t:reverse()
	local new = Vector()
	
	for i = #self, 1, -1 do
		table.insert(new, self[i])
	end
	
	return new
end

-- TODO: This should preserve any potential metatable of o, if possible
function Vectorize(o)
	lemma['assoc-meta'](o, 'length', #o)
	setmetatable(o, mt)
	return o
end

function Vector(...)
	local o = {...}
	return Vectorize(o)
end

function t:seq()
	local o = {}
	lemma['assoc-meta'](o, 'length', 0)
	setmetatable(o, mt)
	return o
end

end
