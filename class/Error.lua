
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

function Error(s)
	local o = {}
	function o:string()
		return s
	end
	setmetatable(o, mt)
	return o
end

end
