
require '../interface/Seq'
require '../interface/Reversible'

do

local function __tostring(e)
	local str = {}
	local curr = e
	
	while not curr['empty?'](curr) do
		table.insert(str, towrite(curr:first()))
		table.insert(str, ' ')
		curr = curr:rest()
	end
	
	table.remove(str)
	return '('..table.concat(str)..')'
end

local function __eq(self, e)
	if lemma.type(self) ~= lemma.type(e) then
		return false
	end
	if self:length() ~= e:length() then
		return false
	end
	if self:length() == 0 then
		return true
	end
	if self:first() ~= e:first() then
		return false
	end
	return (self:rest() == e:rest())
end

local t = {}

function t:length()
	return lemma['get-meta'](self, 'length') or 0
end

local mt = {
	class = 'List',
	implements = { Seq = true, Reversible = true },
	__index = t,
	__tostring = __tostring,
	__eq = __eq
}

function t:cons(...)
	local new = self
	local n = select('#', ...)
	local args = {...}
	
	for i = n, 1, -1 do
		local last = new
		new = { args[i], last }
		lemma['assoc-meta'](new, 'length', last:length() + 1)
		setmetatable(new, mt)
	end
	
	return new
end

function t:first()
	return self[1]
end

function t:rest()
	return self[2]
end

t['empty?'] = function(self)
	return (self[2] == nil)
end

function t:reverse()
	local new = List()
	local curr = self
	
	while not curr['empty?'](curr) do
		new = new:cons(curr:first())
		curr = curr:rest()
	end
	
	return new
end

function List(...)
	local o = {}
	lemma['assoc-meta'](o, 'length', 0)
	setmetatable(o, mt)
	return o:cons(...)
end

function t:seq()
	return self
end

end
