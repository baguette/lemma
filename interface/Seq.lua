---
-- Sequence interface
---

Seq ={}

Seq.sig = {
	'first',
	'rest',
	'cons',
	'empty?',
	'length',
	'seq'
}


for i, v in pairs(Seq.sig) do
	lemma[v] = function(x, ...)
		if x and x[v] then
			return x[v](x, ...)
		else
			return error(tostring(x)..' has type '..type(x)..', not a Seq')
		end
	end
end

-- overwrite cons so it has the usual argument order
lemma.cons = function(x, xs, xss)
	if xs and xss and xss.cons then		-- for HashMaps
		return xss:cons(x, xs)
	elseif xs and xs.cons then
		return xs:cons(x)
	else
		return error('Attempt to cons to '..tostring(xs)..', not a Seq')
	end
end


Seq.lib = {}

function Seq.lib.foldl(f, init, ...)
	local lsts = {...}
	
	if #lsts == 0 then
		return
	elseif not implements(lsts[1], 'Seq') then
		return error('foldl: Seq expected, got '..type(lsts[1]))
	end
	
	local function foldl(f, init, lsts)
		local firsts = {}
		local rests = {}
		
		if lsts[1]:length() > 0 then
			local m = 0
			for i, v in ipairs(lsts) do
				m = m + 1
				firsts[m] = v:first()
				rests[m]  = v:rest()
			end
			return foldl(f, f(init, unpack(firsts, 1, m)), rests)
		else
			return init
		end
	end
	return foldl(f, init, lsts)
end

function Seq.lib.foldr(f, init, ...)
	local lsts = {...}
	
	if #lsts > 0 and not implements(lsts[1], 'Seq') then
		return error('foldr: Seq expected, got '..type(lsts[1]))
	end
	
	if not implements(lsts[1], 'Reversible') then
		return error('foldr: cannot perform right fold on non-reversible seq')
	end
	
	if #lsts > 0 and lsts[1]:length() > 0 then
		for i, v in ipairs(lsts) do
			lsts[i] = v:reverse()
		end
		return Seq.lib.foldl(f, init, unpack(lsts))
	else
		return init
	end
end

local function map(f, lsts)
	local firsts = {}
	local rests = {}

	if not lsts[1]['empty?'](lsts[1]) then
		for i, v in ipairs(lsts) do
			table.insert(firsts, v:first())
			table.insert(rests, v:rest())
		end

		return rests, f(unpack(firsts))
	else
		return nil, List()
	end
end

local function package(r, f)
	return r, f
end

function Seq.lib.map(f, ...)
	local lsts = {...}

	if #lsts == 0 then
		return
	elseif not implements(lsts[1], 'Seq') then
		return error('map: Seq expected, got'..tostring(lsts[1]))
	end

	return Iter(map, f, lsts, package)
end

function Seq.lib.foreach(f, ...)
	local lsts = {...}
	
	if #lsts > 0 and not implements(lsts[1], 'Seq') then
		return error('for-each: Seq expected, got '..type(lsts[1]))
	end
	
	local function foreach(f, lsts)
		local firsts = {}
		local rests = {}
		if #lsts > 0 and not lsts[1]['empty?'](lsts[1]) then
			local m = 0
			for i, v in ipairs(lsts) do
				m = m + 1
				firsts[m] = v:first()
				rests[m] = v:rest()
			end
			f(unpack(firsts, 1, m))
			return foreach(f, rests)
		else
			return nil
		end
	end
	return foreach(f, lsts)
end

function Seq.lib.unpack(lst)
	local t = {}
	local curr = lst
	local n = 0
	
	if not implements(lst, 'Seq') then
		return error('unpack: Seq expected, got '..type(lst)..': '..tostring(lst))
	end
	
	while not curr['empty?'](curr) do
		n = n + 1
		t[n] = curr:first()
		curr = curr:rest()
	end
	
	return unpack(t, 1, n)
end

function Seq.lib.pack(lst, ...)
	local n = select('#', ...)
	local t = {...}
	local q = lst
	
	for i = n, 1, -1 do
		q = q:cons(t[i])
	end
	
	return q
end

function Seq.lib.append(...)
	local t = {...}
	local q = List()
	for i = #t, 1, -1 do
		local v = t[i]
		local s = {Seq.lib.unpack(v)}
		for j = v:length(), 1, -1 do
			q = q:cons(s[j])
		end
	end
	return q
end

function Seq.lib.flatten(...)
	local n = select('#', ...)
	local t = {...}
	local q = {}
	local c = 1

	for i = 1, n do
		local v = t[i]
		if implements(v, seq) then
			local s = {Seq.lib.unpack(v)}
			for j = v:length(), 1, -1 do
				q[c] = s[j]
				c = c + 1
			end
		elseif type(v) == 'table' then
			for j = 1, #v do
				q[c] = v[j]
				c = c + 1
			end
		else
			q[c] = v
			c = c + 1
		end
	end
	
	return Vectorize(q, c)
end

