---
-- The Lemma Evaluator
---

require 'class/List'
require 'class/Vector'
require 'interface/Seq'

function eval(t, env)
	local val, typ
	
	val = t
	typ = type(t)
	
	if not val then
		return val
	end
	
	local switch = {
		Error = function() return val end,
		number = function() return val end,
		string = function() return val end,
		boolean = function() return val end,
		table = function() return val end,
		Vector = function() return val end,
		Symbol = function()
			return env:lookup(val:string())
		end,
		List	= function()
			local op = eval(val:first(), env)
			
			local lst = val:rest()
			
			if type(op) == 'Error' then
				return op
			elseif type(op) == 'Fexpr' then
				return op(env, Seq.lib.unpack(lst))
			elseif type(op) == 'function' then
				lst = Seq.lib.map(function(x) return eval(x, env) end, lst)
				return op(Seq.lib.unpack(lst))
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
