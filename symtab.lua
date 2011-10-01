---
-- Manage a compile-time symbol table.
-- It's represented as a stack of dictionaries.
-- Each time a new function is compiled, a sym-push should occur
-- to set up a stack frame for that function. The function parameters
-- can be added to this frame with sym-new. Symbols within the function
-- body can be resolved with sym-find. At the end of function compilation,
-- sym-pop should occur to discard its locals from the symbol table.
---
require 'class/Error'

---
-- This is ugly.
---
do

local symtab = {}
local uses   = {'lemma'}
local vararg = false

function debug.printsyms()
	print'--------'
	print'Uses'
	print'--------'
	for i, v in ipairs(uses) do
		print(v)
	end
	print(lemma['cur-ns'], '*')
	print'--------'
	print'Symbols'
	print'--------'
	for i, v in ipairs(symtab) do
		for k, w in pairs(v) do
			print(k..' : '..w)
		end
	end
	print'--------'
end

function lemma.use(ns)
	if type(ns) == 'string' then
		table.insert(uses, ns)
	else
		return Error'use: string expected'
	end
end

function splitns(str)
	local _, _, ns, mem = string.find(str, "(.+)/(.+)")
	return ns, mem
end

---
-- Maybe this function should be provided/exported so that quasiquote
-- can qualify symbols...
---
function resolve(str)
	local ns, mem = splitns(str)
	if ns then
		return ns, mem
	end
	ns = lemma['cur-ns']
	mem = str
	for i = #uses, 1, -1 do
		if _NS[uses[i]][mem] ~= nil then
			ns = uses[i]
			break
		end
	end
	if type(ns) ~= 'string' then
		debug.debug()
	end
	return ns, mem
end

function namespace(str)
	local ns, mem = resolve(str)
	if ns then
		if not mem then
			return Error"This should not be a Symbol."
		end
		
		if (ns == '*ns*') then
			ns = lemma['cur-ns']
		end
		
		if _NS[ns] == nil then
			_NS[ns] = {}
		end
		
		local v = {'_NS["', ns, '"]'}
		for m in string.gmatch(mem, '([^%.]+)') do
			table.insert(v, '["')
			table.insert(v, m)
			table.insert(v, '"]')
		end
		return table.concat(v)
	end
	return false
end

lemma['sym-len'] = function()
	return #symtab
end

lemma['sym-vararg?'] = function()
	local v = vararg
	vararg = false
	return v
end

lemma['sym-push'] = function ()
	local t = {0}
	table.insert(symtab, t)
	return t
end

lemma['sym-pop'] = function()
	return table.remove(symtab)
end

lemma['sym-new'] = function(s)
	if type(s) == 'List' then
		local f, r = s:first(), s:rest()
		if  type(f) == 'Symbol'
		and f:string() == 'splice'
		then
			local sym = r:first()
			if type(sym) == 'Symbol' then
				vararg = lemma['sym-new'](sym)
				return '...'
			else
				return Error('Error parsing splice.')
			end
		else
			print('Error in binding for '..f:string()..':'..type(f)..' '..tostring(s))
			return Error('Error in binding')
		end
	elseif type(s) ~= 'Symbol' then
		return Error('Symbol expected, got '..type(s))
	end
	
	if not s.string then
		print 'wtf is happening ?!'
		print(type(s))
		return Error('Error')
	end
	
	local str = s:string()
	local n = #symtab
	
	if n == 0 then
		return namespace(str)
	else
		local ns, s = splitns(str)
		if ns and s then
			return namespace(str)
		end
	end
	
	local a = '_L'..n..'_'..symtab[n][1]
	
	symtab[n][str] = a
	symtab[n][1] = symtab[n][1] + 1
	
	return a
end

lemma['sym-find'] = function(s)
	local str = s:string()
	local n = #symtab
	
	local ns, s = splitns(str)
	if ns and s then
		return namespace(str)
	end
	
	local v = {}
	for m in string.gmatch(str, '([^%.]+)') do
		table.insert(v, m)
	end
	
	if not v[1] then
		return Error"This should not be a Symbol."
	end
	
	for i = n, 1, -1 do
		local q = symtab[i][v[1]]
		if q then
			local r = {q}
			for j = 2, #v do
				table.insert(r, '["')
				table.insert(r, v[j])
				table.insert(r, '"]')
			end
			return table.concat(r)
		end
	end
	
	return namespace(str)
end

end
