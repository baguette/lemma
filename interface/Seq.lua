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

-- TODO: Make this iterative
function Seq.lib.map(f, ...)
	local lsts = {...}
	local firsts = {}
	local rests = {}
	
	if #lsts > 0 and not implements(lsts[1], 'Seq') then
		return Error('map: Seq expected, got '..type(lsts[1]))
	end
	
	if #lsts > 0 and lsts[1]:length() > 0 then
		local m = 0
		for i, v in ipairs(lsts) do
			m = m + 1
			firsts[m] = v:first()
			rests[m]  = v:rest()
		end
		local h = Vector(f(unpack(firsts, 1, m)))
		return Seq.lib.map(f, unpack(rests, 1, m)):cons(unpack(h, 1, h:length()))
	else
		return lsts[1]:seq()
	end
end

function Seq.lib.foreach(f, ...)
	local lsts = {...}
	local firsts = {}
	local rests = {}
	
	if #lsts > 0 and not implements(lsts[1], 'Seq') then
		return Error('for-each: Seq expected, got '..type(lsts[1]))
	end
	
	if #lsts > 0 and lsts[1]:length() > 0 then
		local m = 0
		for i, v in ipairs(lsts) do
			m = m + 1
			firsts[m] = v:first()
			rests[m] = v:rest()
		end
		f(unpack(firsts, 1, m))
		return Seq.lib.foreach(f, unpack(rests, 1, m))
	else
		return nil
	end
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
