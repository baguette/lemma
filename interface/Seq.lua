---
-- Sequence interface
---

Seq ={}

Seq.sig = {
	'first',
	'rest',
	'cons',
	'empty?',
	'seq'
}


for i, v in pairs(Seq.sig) do
	_G[v] = function(x)
		return x[v](x)
	end
end


Seq.lib = {}

function Seq.lib.map(f, ...)
	local lsts = {...}
	local firsts = {}
	local rests = {}
	
	if lsts[1]:first() then
		for i, v in ipairs(lsts) do
			table.insert(firsts, v:first())
			table.insert(rests, v:rest())
		end
		return Seq.lib.map(f, unpack(rests)):cons(f(unpack(firsts)))
	else
		return lsts[1]:seq()
	end
end

function Seq.lib.foreach(f, ...)
	local lsts = {...}
	local firsts = {}
	local rests = {}
	
	if lsts[1]:first() then
		for i, v in ipairs(lsts) do
			table.insert(firsts, v:first())
			table.insert(rests, v:rest())
		end
		f(unpack(firsts))
		return Seq.lib.foreach(f, unpack(rests))
	else
		return lsts[1]:seq()
	end
end

function Seq.lib.unpack(lst)
	local t = {}
	local curr = lst
	
	while not curr['empty?'](curr) do
		table.insert(t, curr:first())
		curr = curr:rest()
	end
	
	return unpack(t)
end
