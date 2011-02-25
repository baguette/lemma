
require '../interface/Seq'
require '../interface/Reversible'

do

local function __tostring(e)
	local str = {'('}
	local curr = e
	
	while not curr['empty?'](curr) do
		table.insert(str, tostring(curr:first()))
		table.insert(str, ' ')
		curr = curr:rest()
	end
	
	table.remove(str)
	table.insert(str, ')')
	return table.concat(str)
end

local t = {}
local mt = {
	class = 'List',
	implements = { Seq, Reversible },
	__index = t,
	__tostring = __tostring
}

function t:cons(x)
	local new = { x, self }
	setmetatable(new, mt)
	return new
end

function t:first()
	return self[1]
end

function t:rest()
	return self[2]
end

t['empty?'] = function(self)
	return (#self == 0)
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

function List()
	local o = {}
	setmetatable(o, mt)
	return o
end

t.seq = List

end
