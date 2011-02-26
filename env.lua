---
-- Lemma Environment
---

require 'class/Fexpr'
require 'class/List'
require 'class/Symbol'
require 'interface/Seq'
require 'type'

---
-- fexprs
---
function stupid(t)
	for k, v in pairs(t) do
		_G[k] = Fexpr(v)
	end
end

stupid{
	def = function(env, ...)
		local args = {...}
	
		for i = 1, #args, 2 do
			local v = args[i + 1]
			env:insert(args[i]:string(), eval(v, env))
		end
	
		return nil
	end,
	
	['set!'] = function(env, ...)
		local args = {...}
		local i = 1
		local ret
	
		while i <= #args do
			local v = args[i + 1]
			ret = env:modify(args[i]:string(), eval(v, env))
			i = i + 2
		end
	
		return ret
	end,
	
	['if'] = function(env, ...)
		local args = {...}
		local test = eval(args[1], env)
		local expr = args[3]
		
		if test then
			expr = args[2]
		end
		
		return eval(expr, env)
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
					exp = exp:cons(_G['quasiquote'](env, v))
				end
			else
				exp = exp:cons(v)
			end
		end
		
		return exp:reverse()
	end,
	
	ev = function(env, ...)
		local arg = ...
		return eval(arg, env)
	end,
	
	fn = function(env, ...)
		local args = {...}
		local arglist = {Seq.lib.unpack(args[1])}
		
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
	end,

	times = function(env, n, expr)
		local val
		local n = eval(n, env)
	
		for i = 1, n do
			val = eval(expr, env)
		end
		return val
	end
}

function splice(q)
	return Seq.lib.unpack(q)
end

---
-- "utility functions"
---

_G['+'] = function(...)
	local sum = 0
	
	for i, v in ipairs{...} do
		sum = sum + v
	end
	
	return sum
end

_G['-'] = function(...)
	local args = {...}
	local diff = args[1] or 0
	
	for i = 2, #args do
		diff = diff - args[i]
	end
	
	return diff
end

_G['*'] = function(...)
	local a, b = ...
	return (a * b)
end

_G['/'] = function(...)
	local a, b = ...
	return (a / b)
end

_G['mod'] = function(...)
	local a, b = ...
	return (a % b)
end

_G['>'] = function(...)
	local a, b = ...
	return (a > b)
end

_G['<'] = function(...)
	local a, b = ...
	return (a < b)
end

_G['or'] = function(...)
	local a, b = ...
	return (a or b)
end

_G['and'] = function(...)
	local a, b = ...
	return (a and b)
end

_G['='] = function(...)
	local a, b = ...
	return (a == b)
end

function str(...)
	local t = {...}
	return table.concat(t)
end

function get(t, k)
	return function(...) return t[k](...) end
end

function method(t, k)
	return function(...) return t[k](t, ...) end
end

---
-- create an environment structure
---
function new_env(env)
	local b
	if env then b = {} else b = _G end
	return {
		bindings = b,
		parent = env,		-- for implementing lexical scope
		lookup = function(self, sym)
			local curr = self
			while curr do
				local val = curr.bindings[sym]
				if val then
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
