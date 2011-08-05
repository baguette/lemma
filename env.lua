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
require 'type'

---
-- Create a function that's been wrapped with wrap.
-- If wrap is nil, the function is not wrapped.
--
-- Currently, its only use is to reduce copypasta in the fn and macro
-- implementations.
---
local function genfunc(wrap)
	wrap = wrap or function(f) return f end
	return function(env, ...)
		local args = {...}
		local arglist = args[1]
		
		if type(arglist) ~= 'Vector' then
			return Error('Expected vector, got '..tostring(arglist))
		end
		
		for i, a in ipairs(arglist) do
			if  type(a) ~= 'Symbol'
			and not (type(a) == 'List'
				and a:first() == Symbol'splice')
			then
				return Error('invalid syntax in arglist: '..tostring(a)..')')
			end
		end
		
		return wrap(function(...)
			local largs = {...}
			local env = env:enter()
			local val
			
			for i = 1, #arglist do
				local a = arglist[i]
				
				if type(a) == 'Symbol' then
					env:insert(a:string(), largs[i])
				elseif type(a) == 'List' then
					if a:first():string() == 'splice' then
						local lst = List()
						for k = #largs, i, -1 do
							lst = lst:cons(largs[k])
						end
						env:insert(a:rest():first():string(), lst)
						i = #arglist + 1
					end
				end
			end
			
			for i = 2, #args do
				val = eval(args[i], env)
			end
			
			return val
		end)
	end
end

---
-- fexprs
---
;(function(t)
	for k, v in pairs(t) do
		lemma[k] = Fexpr(v)
	end
end){
	def = function(env, ...)
		local args = {...}
	
		for i = 1, #args, 2 do
			local v = args[i + 1]
			
			if type(args[i]) ~= 'Symbol' then
				return Error('attempt to def a non-variable: '..tostring(args[i]))
			end
			
			v = eval(v, env)
			if type(v) == 'Error' then
				return v
			end
			
			env:insert(args[i]:string(), v)
		end
	
		return nil
	end,
	
	['set!'] = function(env, ...)
		local args = {...}
		local i = 1
		local ret
	
		while i <= #args do
			local s = args[i]
			local v = args[i + 1]
			
			if type(s) ~= 'Symbol' then
				return Error('in set!: '..tostring(s)..' is not a variable')
			end
			
			s = s:string()
			ret = env:lookup(s)
			
			if not ret then
				return Error('in set!: '..s..' is undefined')
			end
			
			v = eval(v, env)
			if type(v) == 'Error' then
				return v
			end
			
			ret = env:modify(s, v)
			i = i + 2
		end
	
		return ret
	end,
	
	['cond'] = function(env, ...)
		local args = {...}
		
		for i = 1, #args, 2 do
			local test = eval(args[i], env)
			
			if test then
				return eval(args[i+1], env)
			end
		end
		
		return nil
	end,
	
	quote = function(env, ...)
		return ...
	end,
	
	unquote = function(env, ...)
		local exp = ...
		local val = {eval(exp, env)}
		
		return unpack(val)
	end,
	
	quasiquote = function(env, ...)
		local args = ...
		local exp = args:seq()
		
		for i, v in ipairs{Seq.lib.unpack(args)} do
			if implements(v, 'Seq') then
				local car = v:first()
				if car == Symbol'unquote' then
					local val = {eval(v, env)}
					exp = exp:cons(Seq.lib.unpack(v:seq():cons(unpack(val)):reverse()))
				elseif car == Symbol'quasiquote' then
					exp = exp:cons(v)
				else
					exp = exp:cons(lemma['quasiquote'](env, v))
				end
			else
				exp = exp:cons(v)
			end
		end
		
		return exp:reverse()
	end,
	
	getenv = function(env, ...)
		return env
	end,
	
	fn = genfunc(),
	
	macro = genfunc(Macro),
	
	expand = function(env, ...)
		local form = ...
		
		if type(form) == 'List' then
			local head = eval(form:first(), env)
			if type(head) == 'Macro' then
				return head(Seq.lib.unpack(form:rest()))
			end
			return Error'Cannot expand non-macro.'
		end
		return Error'Cannot expand non-macro (list).'
	end
}

function lemma.splice(q)
	return Seq.lib.unpack(q)
end

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
 ['>']   = function(a, b) return a > b end,
 ['<']   = function(a, b) return a < b end,
 ['>=']  = function(a, b) return a >= b end,
 ['<=']  = function(a, b) return a <= b end,
 ['or']  = function(a, b) return a or b end,
 ['and'] = function(a, b) return a and b end
}

lemma['not'] = function(a)
	return not a
end

function lemma.str(...)
	local t = {...}
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
		return Error'attempt to index table with nil'
	end
	if not t then
		return Error('attempt to index nil ['..k..']')
	end
	return t[k]
end

function lemma.method(t, k)
	if not k then
		return Error'attempt to index table with nil'
	end
	if not t then
		return Error('attempt to index nil ['..k..']')
	end
	if not t[k] then
		return Error('method is nil ['..k..']')
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
lemma['*namespaces*'] = {lua = _G, lemma = lemma}
lemma['*ns*'] = 'lemma'

---
-- Copy some stuff from lua
---
lemma.eval = eval
lemma.read = read
lemma.write = write
lemma.print = print
lemma.map = Seq.lib.map
lemma['for-each'] = Seq.lib.foreach


function string.split(s, p)
	f, s, k = s:gmatch(p)
	return f(s, k)
end

---
-- create an environment structure
---
function new_env(env)
	local b
	if env then b = {} else b = lemma['*namespaces*'][lemma['*ns*']] end
	return {
		bindings = b,
		parent = env,		-- for implementing lexical scope
		lookup = function(self, sym, mod, insert)
			local patt = symbol_patterns()
			local curr = self
			local ns, rest = sym:split(patt.ns..'/'..patt.ns)
			
			if ns and rest then
				curr = { bindings = lemma['*namespaces*'][ns] }
				sym = rest
			end
			local path = {}
			for k in sym:gmatch(patt.table..'%.?') do
				table.insert(path, k)
			end
			if #path == 0 then
				table.insert(path, sym)
			end
			while curr do
				local old = curr.bindings
				local val = old[path[1]]
				if val ~= nil then
					local i = 2
					while path[i] do
						old = val
						val = val[path[i]]
						i = i + 1
					end
					if mod then
						old[path[i-1]] = mod
						return mod
					else
						return val
					end
				else
					if insert then
						old[path[1]] = mod
						return mod
					end
				end
				
				curr = curr.parent
			end
		end,
		modify = function(self, sym, val)
			return self:lookup(sym, val)
		end,
		insert = function(self, sym, val)
			return self:lookup(sym, val, true)
		end,
		enter = new_env,
		leave = function(self)
			if self.parent then
				self.bindings = self.parent.bindings
				self.parent = self.parent.parent
			end
		end
	}
end

---
-- The global environment
---
env = new_env()

---
-- Switch environments
---
function lemma.ns(name)
	if type(name) ~= 'string' then
		return Error('ns: Expected string, got '..type(name))
	end
	
	-- Create an empty namespace if the specified name doesn't exist
	if not lemma['*namespaces*'][name] then
		lemma['*namespaces*'][name] = {}
	end
	
	-- Do the switch, then update
	lemma['*ns*'] = name
	env = new_env()
	update_prompt()
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
