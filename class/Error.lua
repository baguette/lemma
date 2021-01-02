
do

local function __tostring(e)
	return e:string()
end

local t = {}
local mt = {
	class = 'Error',
	implements = nil,
	__index = t,
	__tostring = __tostring
}

local cache = {}

function Error(s, trace)
	local o = {}
	setmetatable(o, mt)
	
	if trace then
		if lemma.type(trace) == 'Error' then
			trace = trace:string()
		end
		s = trace..'\n'..s
	elseif cache[s] then
		return cache[s]
	else
		if s then
			cache[s] = o
		end
	end
	
	function o:string()
		return tostring(s)
	end
	
	return o
end

end
