
do
	local t = {}

	function t:conj(...)
		local n = select('#', ...)
		local args = {...}

		for i = 1, n do
			self[args[i]] = true
		end
	end

	t['remove!'] = function(self, x)
		local r = self[x]
		self[x] = nil
		return r
	end

	t['contains?'] = function(self, x)
		return self[x] or false
	end

	local mt = {
		__class = 'Set',
		__index = t
	}

	function Set(...)
		local o = {}
		setmetatable(o, mt)
		o:conj(...)
		return o
	end
end

