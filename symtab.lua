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

do

local symtab = {}

local function namespace(str)
	local _, _, ns, mem = string.find(str, "(.+)/(.+)")
	if ns then
		if not mem then
			return Error"This should not be a Symbol."
		end
		
		-- TODO: make a vector of namespaces that are currently referred to
		--       and lookup symbols in them if no symbols is found
		if ns == '*ns*' then
			ns = lemma['cur-ns']
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

lemma['sym-push'] = function ()
	local t = {0}
	table.insert(symtab, t)
	return t
end

lemma['sym-pop'] = function()
	return table.remove(symtab)
end

lemma['sym-new'] = function(s)
	local str = s:string()
	local n = #symtab
	
	local ns = namespace(str)
	if ns then
		return ns
	elseif n == 0 then
		return namespace('*ns*/'..str)
	end
	
	local a = '_L'..n..'_'..symtab[n][1]
	
	symtab[n][str] = a
	symtab[n][1] = symtab[n][1] + 1
	
	return a
end

lemma['sym-find'] = function(s)
	local str = s:string()
	local n = #symtab
	
	local ns = namespace(str)
	if ns then
		return ns
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
	
	return namespace('*ns*/'..str)
end

end
