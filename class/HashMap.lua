
require '../interface/Seq'
require '../interface/Reversible'

do

local function __tostring(e)
	local str = {}
	
	for k, v in pairs(e) do
		table.insert(str, tostring(k))
		table.insert(str, ' ')
		table.insert(str, tostring(v))
		table.insert(str, ', ')
	end
	
	table.remove(str)		-- get rid of the extraneous comma
	return '{'..table.concat(str)..'}'
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
	class = 'HashMap',
	implements = { 'Seq' },
	__index = t,
	__tostring = __tostring,
	__call = __call
}

function t:cons(...)
	local new = HashMap()
	local args = {...}
	
	for k, v in pairs(self) do
		new[k] = v
	end
	
	for i = 1, #args, 2 do
		new[args[i]] = args[i+1]
	end
	
	lemma['assoc-meta'](new, 'length', self:length() + #args / 2)
	return new
end

function t:length()
	return lemma['get-meta'](self, 'length') or 0
end

function t:first()
	for k, v in pairs(self) do
		return Vector(k, v)
	end
end

function t:rest()
	local new = HashMap()
	local skip = false
	
	for k, v in pairs(self) do
		if skip then
			new[k] = v
		else
			skip = true
		end
	end
	
	lemma['assoc-meta'](new, 'length', self:length() - 1)
	
	return new
end

t['empty?'] = function(self)
	return (self:length() == 0)
end

function Mapify(o)
	local len = 0
	for k, v in pairs(o) do
		len = len + 1
	end
	lemma['assoc-meta'](o, 'length', len)
	setmetatable(o, mt)
	return o
end

function HashMap(...)
	local args = {...}
	local o = {}
	
	for i = 1, #args, 2 do
		o[args[i]] = args[i+1]
	end
	
	return Mapify(o)
end

function t:seq()
	local o = {}
	setmetatable(o, mt)
	return o
end

end
