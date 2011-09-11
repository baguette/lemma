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

function Seq.lib.map(f, ...)
	local lsts = {...}
	local firsts = {}
	local rests = {}
	
	if #lsts > 0 and not implements(lsts[1], 'Seq') then
		return Error'Seq expected'
	end
	
	if #lsts > 0 and lsts[1]:first() then
		for i, v in ipairs(lsts) do
			table.insert(firsts, v:first())
			table.insert(rests, v:rest())
		end
		local h = {f(unpack(firsts))}
		return Seq.lib.map(f, unpack(rests)):cons(unpack(h))
	else
		return lsts[1]:seq()
	end
end

function Seq.lib.foreach(f, ...)
	local lsts = {...}
	local firsts = {}
	local rests = {}
	
	if #lsts > 0 and not implements(lsts[1], 'Seq') then
		return Error'Seq expected'
	end
	
	if #lsts > 0 and lsts[1]:first() then
		for i, v in ipairs(lsts) do
			table.insert(firsts, v:first())
			table.insert(rests, v:rest())
		end
		f(unpack(firsts))
		return Seq.lib.foreach(f, unpack(rests))
	else
		return nil
	end
end

function Seq.lib.unpack(lst)
	local t = {}
	local curr = lst
	
	if not implements(lst, 'Seq') then
		return Error'Seq expected'
	end
	
	while not curr['empty?'](curr) do
		table.insert(t, curr:first())
		curr = curr:rest()
	end
	
	return unpack(t)
end

function Seq.lib.pack(lst, ...)
	local t = {...}
	local q = lst:seq()
	
	for i = #t, 1, -1 do
		q = q:cons(t[i])
	end
	
	return q
end
