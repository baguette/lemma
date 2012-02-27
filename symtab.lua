---
-- Manage a compile-time symbol table.
-- It's represented as a stack of dictionaries.
-- Each time a new function is compiled, a sym-push should occur
-- to set up a stack frame for that function. The function parameters
-- can be added to this frame with sym-new. Symbols within the function
-- body can be resolved with sym-find. At the end of function compilation,
-- sym-pop should occur to discard its locals from the symbol table.
---
require 'class/Set'

---
-- This is ugly... but it's only temporary.
-- I am seriously reconsidering namespaces... they just end up being
-- awkward when compiled to Lua.  Maybe there's a better way?
---
do

local symtab = {}
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



local function ns_attach(t)
	local o = getmetatable(t) or {}
	o.__uses = o.__uses or {}

	local function find_use(s, k)
		local uses = o.__uses
		for i = #uses, 1, -1 do
			-- Prevent infinite recursion looking for a symbol
			if uses[i] == lemma['cur-ns'] then
				return nil
			end
			local u = _G[uses[i]][k]
			if u ~= nil then return u end
		end
		return nil
	end

	-- favor any existing indexers when attaching
	if o.__index then
		local f = o.__index
		local function lookup(s, k)
			local v = nil
			if type(f) == 'table' then
				v = f[k]
			elseif type(f) == 'function' then
				v = f(s, k)
			end
			return v or find_use(s, k)
		end
		o.__index = lookup
	else
		o.__index = find_use
	end

	return setmetatable(t, o)
end

-- Mark the lemma namespace as a use-able namespace
ns_attach(lemma)

lemma['add-ns'] = function(ns)
	if _G[ns] == nil then
		_G[ns] = ns_attach{}
		lemma.use('lemma', ns)
	end
end

function lemma.use(ns, cur)
	if type(ns) == 'string' then
		local t = cur or lemma['cur-ns']
		if type(_G[t]) == 'table' then
			local o = getmetatable(_G[t])
			if not o then
				error'current namespace is not a namespace?!'
			end
			if type(_G[ns]) == 'table' then
				table.insert(o.__uses, ns)
			else
				return error('use: '..ns..' is not a known namespace')
			end
		end
	else
		return error'use: string expected'
	end
end

local function splitns(str)
	local _, _, ns, mem = string.find(str, "(.+)/(.+)")
	return ns, mem
end

---
-- Maybe this function should be provided/exported so that quasiquote
-- can qualify symbols...
---
local function resolve(str)
	local ns, mem = splitns(str)
	if ns and mem then
		return ns, mem
	end
	mem = str
	ns = lemma['cur-ns']
	if type(ns) ~= 'string' then
		debug.debug()
	end
	return ns, mem
end

local function namespace(str)
	local ns, mem = resolve(str)
	if ns then
		if not mem then
			return error"read error: This should not be a Symbol."
		end
		
		if (ns == '*ns*') then
			ns = lemma['cur-ns']
		end
		
		if not _G[ns] then
			return error('error: '..ns..' is not a known namespace.')
		end
		
		local v = {'_G["', ns, '"]'}
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
	
	local ns, sp = splitns(str)
	if ns and sp then
		return namespace(str)
	else
		if n == 0 then
			return namespace('*ns*/'..str)
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
		return error"reader error: This should not be a Symbol."
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
