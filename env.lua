---
-- Lemma Environment
---

require 'class/Fexpr'
require 'class/Macro'
require 'class/List'
require 'class/Vector'
require 'class/HashMap'
require 'class/Symbol'
require 'class/Error'
require 'interface/Seq'
require 'symtab'
require 'type'

---
-- Some Lua functions that could really use customizing.
---
tostring, print = (function()
	local xtostring = tostring
	return function(s)
		if type(s) == 'string' then
			return string.format('%q', s)
		elseif s == false then
			return "false"
		elseif s == nil then
			return "nil"
		end
		return xtostring(s)
	end,
	function(...)
		local n = select('#', ...)
		local args = {...}
		
		for i = 1, n do
			args[i] = xtostring(args[i])
		end
		
		io.write(table.concat(args, '\t'))
		io.write'\n'
	end
end)()

---
-- Write an external representation of t to stdout
---
function write(...)
	local n = select('#', ...)
	local args = {...}
	
	if n > 0 then
		for i = 1, n do
			io.write(tostring(args[i]))
			io.write(' ')
		end
	else
		io.write('nil')
	end
	io.write('\n')
end

lemma.splice = Seq.lib.unpack
lemma.unsplice = Seq.lib.pack
lemma.append = Seq.lib.append
lemma.flatten = Seq.lib.flatten

---
-- "utility functions"
---

;(function(t)
	for k, v in pairs(t) do
		lemma[k] = function(...)
			local args = {...}
			local diff = args[1] or 0
			
			for i = 2, #args do
				diff = v(diff, args[i])
			end
	
			return diff
		end
	end
end){
 ['+']   = function(a, b) return a + b end,
 ['-']   = function(a, b) return a - b end,
 ['*']   = function(a, b) return a * b end,
 ['/']   = function(a, b) return a / b end,
 ['mod'] = function(a, b) return a % b end
}

;(function(t)
	for k, v in pairs(t) do
		lemma[k] = function(...)
			local a, b = ...
			
			return v(a, b)
		end
	end
end){
 ['=']   = function(a, b) return a == b end,
 ['not=']  = function(a, b) return a ~= b end,
 ['>']   = function(a, b) return a > b end,
 ['<']   = function(a, b) return a < b end,
 ['>=']  = function(a, b) return a >= b end,
 ['<=']  = function(a, b) return a <= b end
}

lemma['not'] = function(a)
	return not a
end

function lemma.str(...)
	local n = select('#', ...)
	local t = {...}
	for i = 1, n do
		local v = t[i]
		if type(v) ~= 'string' then
			t[i] = tostring(v)
		end
	end
	return table.concat(t)
end

lemma.vec = Vector
lemma['hash-map'] = HashMap

function lemma.keys(t)
	local list = List()
	
	for k in pairs(t) do
		list = list:cons(k)
	end
	
	return list:reverse()
end

function lemma.values(t)
	local list = List()
	
	for _, v in pairs(t) do
		list = list:cons(v)
	end
	
	return list:reverse()
end

function lemma.get(t, k)
	if not k then
		return Error'get: attempt to index table with nil'
	end
	if not t then
		return Error('get: attempt to index nil ['..k..']')
	end
	return t[k]
end

function lemma.method(t, k, ...)
	if k == nil then
		return Error'method: attempt to index table with nil'
	end
	if t == nil then
		return Error('method: attempt to index nil ['..k..']')
	end
	k = k:string()
	if t[k] == nil then
		return Error('method: method is nil ['..k..']')
	end
	return function(...)
		return t[k](t, ...)
	end
end

---
-- This table stores any metadata associated with a particular object.
-- It uses weak keys so that the metadata will be garbage collected if
-- the associated object is garbage collected.
---
lemma['*metadata*'] = {}
setmetatable(lemma['*metadata*'], { __mode = 'k' })

---
-- Set up the namespaces. All of the usual global stuff in Lua is moved
-- into a lua namespace, and the lemma namespace becomes the default.
---
_NS = {lua = _G, lemma = lemma}  -- this is going away soon
lua = _G   -- give stock lua stuff its own namespace
-- lemma['*namespaces*'] = _NS
lemma['*ns*'] = 'lemma'

---
-- Copy some stuff from lua
---
lemma.eval = eval
lemma.read = read
lemma.write = write
lemma.print = print
lemma.type = type
lemma.tostring = tostring
lemma.foldl = Seq.lib.foldl
lemma.foldr = Seq.lib.foldr
lemma.map = Seq.lib.map
lemma['for-each'] = Seq.lib.foreach

function lemma.undefined()
	return nil
end

function string.split(s, p)
	f, s, k = s:gmatch(p)
	return f(s, k)
end

lemma['assoc-meta'] = function(t, k, v)
	if not lemma['*metadata*'][t] then
		lemma['*metadata*'][t] = { [k] = v }
	else
		lemma['*metadata*'][t][k] = v
	end
end

lemma['get-meta'] = function(t, k)
	if lemma['*metadata*'][t] then
		return lemma['*metadata*'][t][k]
	end
end

function lemma.length(t)
	if implements(t, 'Seq') then
		return t:length()
	elseif type(t) == 'table' then
		return #t
	elseif type(t) == 'string' then
		return string.len(t)
	else
		return Error("Don't know how to get length of "..type(t))
	end
end
