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
require 'class/Iter'
require 'interface/Seq'
require 'symtab'
require 'type'

---
-- Some Lua functions that could really use customizing.
---
towrite, print = (function()
	return function(s)
		if type(s) == 'string' then
			return string.format('%q', s)
		elseif s == false then
			return "false"
		elseif s == nil then
			return "nil"
		end
		return tostring(s)
	end,
	function(...)
		local n = select('#', ...)
		local args = {...}
		
		for i = 1, n do
			args[i] = tostring(args[i])
		end
		
		io.write(table.concat(args, '\t'))
		io.write'\n'
	end
end)()

function lemma.rawstring(t)
	local old = getmetatable(t)
	setmetatable(t, nil)
	local s = tostring(t)
	setmetatable(t, old)
	return s
end

---
-- Write an external representation of t to stdout
---
function write(...)
	local n = select('#', ...)
	local args = {...}

	if n > 0 then
		for i = 1, n do
			io.write(towrite(args[i]))
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
		lemma[k] = function(a, b)
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

lemma['id?'] = function(a, b)
	return rawequal(a, b)
end

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

lemma.vector = Vector
lemma['hash-map'] = HashMap

function lemma.vec(seq)
	return Vector(Seq.lib.unpack(seq))
end

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
	if type(k) == 'Symbol' then
		k = k:string()             -- TODO: is the really a good idea?
	end
	if not k then
		return error'get: attempt to index table with nil'
	end
	if not t then
		return error('get: attempt to index nil ['..k..']')
	end
	return t[k]
end

lemma['table-set!'] = function(t, k, v)
	if not k then
		return error'table-set!: attempt to index table with nil'
	end
	if not t then
		return error('table-set!: attempt to index nil ['..k..']')
	end
	t[k] = v
	return v
end

---
-- Create a raw Lua table with array part a (optional) and hash part h.
-- If no arguments are specified, returns an empty table.
---
function lemma.table(a, h)
	if not h then
		h = a
		a = nil
	end
	local t
	if a then
		t = {Seq.lib.unpack(a)}
	else
		t = {}
	end
	if h then
		for k, v in h do
			t[k] = v
		end
	end
	return t
end

function lemma.method(k)
	if type(k) ~= 'string' then
		return error('method: expected string, got '..tostring(k))
	end
	--k = k:string()
	
	return function(t, ...)
		if t == nil then
			return error('method: attempt to index nil ['..k..']')
		end
		if t[k] == nil then
			return error('method: method is nil ['..k..']')
		end
		return t[k](t, ...)
	end
end

---
-- Set up the namespaces. All of the usual global stuff in Lua is moved
-- into a lua namespace, and the lemma namespace becomes the default.
---
lemma.lua = _G   -- give stock lua stuff its own namespace

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
lemma.iter = Iter

function lemma.undefined()
	return nil
end

function lemma.take(n, seq)
	if type(n) ~= 'number' then
		return error('take: number expected, got ', tostring(n))
	end
	if not implements(seq, 'Seq') then
		return error('take: seq expected, got ', tostring(seq))
	end
	lst = {}
	for i = 1, n do
		if seq['empty?'](seq) then
			n = i - 1
			break
		end
		lst[i] = seq:first()
		seq = seq:rest()
	end
	return List(unpack(lst, 1, n))
end

function lemma.drop(n, seq)
	if type(n) ~= 'number' then
		return error('take: number expected, got ', tostring(n))
	end
	if not implements(seq, 'Seq') then
		return error('take: seq expected, got ', tostring(seq))
	end
	for i = 1, n do
		if seq['empty?'](seq) then
			break
		end
		seq = seq:rest()
	end
	return seq
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
		return error("Don't know how to get length of "..type(t))
	end
end

function lemma.range(a, b, by)
	-- by defaults to 1
	by = by or 1
	
	-- make a optional
	if not b then
		a, b = by, a
	end
	
	a = a - by
	
	local function until_inc(s, v)
		local n = v + by
		if n <= s then
			return n
		end
		return nil
	end
	
	return Iter(until_inc, b, a)
end


