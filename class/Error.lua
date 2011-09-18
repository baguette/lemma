
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

function Error(s, trace)
	local o = {}
	setmetatable(o, mt)
	
	if trace then
		if type(trace) == 'Error' then
			trace = trace:string()
		end
		s = trace..'\n'..s
	elseif cache[s] then
		return cache[s]
	else
		cache[s] = o
	end
	
	function o:string()
		return s
	end
	
	return o
end

end
