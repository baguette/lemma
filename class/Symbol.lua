---
-- Get the Symbol represented by str
---

do

local function __tostring(e)
	return e:string()
end

local t = {}
local mt = {
	class = 'Symbol',
	implements = nil,
	__index = t,
	__tostring = __tostring
}

local cache = {}

function Symbol(str)
	if cache[str] then
		return cache[str]
	end
	
	local o = {}
	function o:string()
		return str
	end
	setmetatable(o, mt)
	
	cache[str] = o
	return o
end

end
