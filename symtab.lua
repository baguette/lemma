---
-- Manage a compile-time symbol table.
-- It's represented as a stack of dictionaries.
-- Each time a new function is compiled, a sym-push should occur
-- to set up a stack frame for that function. The function parameters
-- can be added to this frame with sym-new. Symbols within the function
-- body can be resolved with sym-find. At the end of function compilation,
-- sym-pop should occur to discard its locals from the symbol table.
---

---
-- This is ugly... but it's only temporary.
---
do

local symtab = {}
local vararg = false
local symfile
local loctab = {}

function debug.printsyms()
	print'--------'
	print'Uses'
	print'--------'
	for i, v in ipairs(uses) do
		print(v)
	end
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

local function compile_sym(str)
	local v = {'lemma'}
	for m in string.gmatch(str, '([^%.]+)') do
		table.insert(v, '["')
		table.insert(v, m)
		table.insert(v, '"]')
	end
	return table.concat(v)
end

lemma['sym-set-file'] = function(s)
	symfile = '#lemma:file:'..s
	lemma['*metadata*'][symfile] = lemma['*metadata*'][symfile] or {}
	loctab[symfile] = loctab[symfile] or {}
end

lemma['sym-set-file']('lma-repl')

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

lemma['sym-new'] = function(s, loc)
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
				return error('Error parsing splice.')
			end
		else
			return error('Error in binding for '..
			             f:string()..':'..type(f)..' '..tostring(s))
		end
	elseif type(s) ~= 'Symbol' then
		return error('Symbol expected, got '..type(s))
	end
	
	if not s.string then
		return error('Error: wtf is happening?!'..type(s))
	end
	
	local str = s:string()
	local n = #symtab
	
	if n == 0 then
		if loc then
			loctab[symfile][str] = "lemma['*metadata*']['"..symfile.."']['"..str.."']"
			return loctab[symfile][str]
		else
			return compile_sym(str)
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
	
	local v = {}
	for m in string.gmatch(str, '([^%.]+)') do
		table.insert(v, m)
	end
	
	if not v[1] then
		return error"reader error: This should not be a Symbol."
	end
	
	for i = n, 0, -1 do
		local q
		if i == 0 then
			q = loctab[symfile][v[1]]
		else
			q = symtab[i][v[1]]
		end
	
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
	
	return compile_sym(str)
end

end
