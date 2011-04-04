---
-- Lemma Environment
---

require 'class/Fexpr'
require 'class/List'
require 'class/Symbol'
require 'class/Error'
require 'interface/Seq'
require 'type'

--[[-- failed experiment?
_G = { lua = _G }
setfenv(0, _G)
--]]--

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
		local exp = List()
		
		for i, v in ipairs{Seq.lib.unpack(args)} do
			if  type(v) == 'List'
			then
				local car = v:first()
				if type(car) == 'Symbol' and car:string() == 'unquote' then
					local val = {eval(v, env)}
					if val[1] then
						exp = exp:cons(Seq.lib.unpack(List():cons(unpack(val)):reverse()))
					end
				elseif type(car) == 'Symbol' and car:string() == 'quasiquote' then
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
	
	fn = function(env, ...)
		local args = {...}
		local arglist = {Seq.lib.unpack(args[1])}
		
		for i, a in ipairs(arglist) do
			if type(a) ~= 'Symbol'
			and not (type(a) == 'List' and type(a:first()) == 'Symbol'
			    and a:first():string() == 'splice')
			then
				return Error('invalid syntax in arglist ('..tostring(a)..')')
			end
		end
		
		return function(...)
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
		end
	end,
	
	macro = function(env, ...)
		local args = {...}
		local arglist = {Seq.lib.unpack(args[1])}
		
		for i, a in ipairs(arglist) do
			if type(a) ~= 'Symbol'
			and not (type(a) == 'List' and type(a:first()) == 'Symbol'
			    and a:first():string() == 'splice')
			then
				return Error('invalid syntax in arglist ('..tostring(a)..')')
			end
		end
		
		return Fexpr(
			function(env, ...)
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
				
				env:leave()
			
				return eval(val, env)
			end
		)
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

function lemma.str(...)
	local t = {...}
	return table.concat(t)
end

function lemma.vector(...)
	return {...}
end

function lemma.assoc(t, ...)
	local args = {...}
	
	for i = 1, #args, 2 do
		t[args[i]] = args[i+1]
	end
	
	return t
end

function lemma.hashmap(...)
	return lemma.assoc({}, ...)
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
	if not k then
		return Error'attempt to index table with nil'
	end
	if not t then
		return Error('attempt to index nil ['..k..']')
	end
	return t[k]
end

function lemma.memfn(t, k)
	if not k then
		return Error'attempt to index table with nil'
	end
	if not t then
		return Error('attempt to index nil ['..k..']')
	end
	if not t[k] then
		return Error('member function is nil ['..k..']')
	end
	return function(...)
		return t[k](...)
	end
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
-- Copy some stuff from lua
---
lemma.lua = _G
lemma.eval = eval
lemma.read = read
lemma.write = write
lemma.print = print
lemma.map = Seq.lib.map


function string.split(s, p)
	local strs = {}
	for k in string.gmatch(s, p) do
		table.insert(strs, k)
	end
	return (#strs > 0) and strs or nil
end

---
-- create an environment structure
---
function new_env(env)
	local b
	if env then b = {} else b = lemma end
	return {
		bindings = b,
		parent = env,		-- for implementing lexical scope
		lookup = function(self, sym)
			local curr = self
			local path = sym:split(symbol_pattern()..'%.?') or {sym}
			while curr do
				local val = curr.bindings[path[1]]
				if val then
					local i = 2
					while path[i] do
						val = val[path[i]]
						i = i + 1
					end
					return val
				end
				curr = curr.parent
			end
		end,
		modify = function(self, sym, val)
			local curr = self
			while curr do
				local v = curr.bindings[sym]
				if v then
					curr.bindings[sym] = val
					return val
				end
				curr = curr.parent
			end
			return nil
		end,
		insert = function(self, sym, val)
			self.bindings[sym] = val
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
