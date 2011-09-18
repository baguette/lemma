---
-- The Lemma Evaluator
---

require 'env'
require 'class/List'
require 'class/Vector'
require 'class/PreHashMap'
require 'class/HashMap'
require 'class/Iter'
require 'interface/Seq'

stacktrace={}

function eval(t, env)
	local val, typ
	
	val = t
	typ = type(t)
	
	if not val then
		return val
	end
	
	local function pass()
		return val
	end
	
	local function dovec()
		return Seq.lib.map(
			function(f)
				return eval(f, env)
			end, val
		)
	end
	
	local function dohash()
		return HashMap(Seq.lib.unpack(dovec()))
	end
	
	local switch = {
		Error   = function() print(val:string()) end,
		number  = pass,
		Number  = function() return tonumber(val:string()) end,
		string  = pass,
		boolean = pass,
		Nil     = function() return nil end,
		['nil'] = pass,
		table   = pass,
		Vector  = dovec,
		PreHashMap = dohash,
		HashMap = pass,
		Symbol  = function()
			return env:lookup(val:string())
		end,
		List	= function()
			local op = eval(val:first(), env)
			
			local lst = val:rest()
			
			if type(op) == 'Error' then
				return Error('in eval: op was Error', op)
			elseif type(op) == 'Fexpr' then
			--	print(Seq.lib.unpack(lst))
				return op.func(env, Seq.lib.unpack(lst))
			elseif type(op) == 'Macro' then
				return eval(op.func(Seq.lib.unpack(lst)), env)
			elseif type(op) == 'function'
			or     type(op) == 'HashMap'
			or     type(op) == 'Vector'
			then
				lst = Seq.lib.map(function(x) return eval(x, env) end, lst)
				local rets = {pcall(op, Seq.lib.unpack(lst))}
				if rets[1] == true then
					return unpack(rets, 2)
				else
					return Error('eval: error calling '..tostring(val:first()),
					             rets[2])
				end
			elseif type(op) == 'table'
			or (type(op) == 'userdata' and getmetatable(op).__index)
			then
				local key = eval(lst:first(), env)
				return lemma.get(op, key)
			end
			
			return Error(tostring(val:first())..' is not a function\n')
		end
	}
	
	local evaluator = switch[typ]
	if not evaluator then
		return Error('cannot evaluate unknown type: '..typ..'\n')
	end
	return evaluator()
end
