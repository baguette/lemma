
do

local function __tostring(e)
	return e:string()
end

local t = {}
local mt = {
	class = 'Error',
	implements = {},
	__index = t,
	__tostring = __tostring
}

local cache = {}

function Error(s)
	if cache[s] then
		return cache[s]
	end
	
	local o = {}
	function o:string()
		return s
	end
	setmetatable(o, mt)
	cache[s] = o
	return o
end

end
