---
-- An association vector to store the items of a hash map before they are
-- evaluated. The evaluated pairs should then be placed into a proper HashMap
---
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
	return '%['..table.concat(str)..']'
end

local t = {}
local mt = {
	class = 'PreHashMap',
	implements = { Seq = true, Reversible = true },
	__index = getmetatable(Vector()).__index,
	__tostring = __tostring
}

function PreHashMap(...)
	local o = Vector(...)
	setmetatable(o, mt)
	return o
end

end
