---
-- Sequence interface
---

Seq ={}

Seq.sig = {
	'first',
	'rest',
--	'cons',
	'empty?',
	'length',
	'seq'
}


for i, v in pairs(Seq.sig) do
	lemma[v] = function(x, ...)
		if x and x[v] then
			return x[v](x, ...)
		else
			return Error(tostring(x)..' has type '..type(x)..', not a Seq')
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
		return Error('Attempt to cons to '..tostring(xs)..', not a Seq')
	end
end


Seq.lib = {}

function Seq.lib.foldl(f, init, ...)
	local lsts = {...}
	
	if #lsts == 0 then
		return
	elseif not implements(lsts[1], 'Seq') then
		return Error('foldl: Seq expected, got '..type(lsts[1]))
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
		return Error('foldr: Seq expected, got '..type(lsts[1]))
	end
	
	if not implements(lsts[1], 'Reversible') then
		return Error('foldr: cannot perform right fold on non-reversible seq')
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

function Seq.lib.map(f, ...)
	local a = ...
	return Seq.lib.foldr(
		function(init, ...)
			return init:cons(f(...))
		end,
		a:seq(),
		...)
end

function Seq.lib.foreach(f, ...)
	local lsts = {...}
	
	if #lsts > 0 and not implements(lsts[1], 'Seq') then
		return Error('for-each: Seq expected, got '..type(lsts[1]))
	end
	
	local function foreach(f, lsts)
		local firsts = {}
		local rests = {}
		if #lsts > 0 and lsts[1]:length() > 0 then
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
		return Error('unpack: Seq expected, got '..type(lst)..': '..tostring(lst))
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
	local q = lst:seq()
	
	for i = n, 1, -1 do
		q = q:cons(t[i])
	end
	
	return q
end
