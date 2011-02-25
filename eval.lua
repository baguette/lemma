---
-- The Lemma Evaluator
---

require 'class/List'
require 'interface/Seq'

function eval(t, env)
	local val, typ
	
	val = t
	typ = type(t)
	
	local switch = {
		number = function() return val end,
		string = function() return val end,
		Symbol = function()
			return env:lookup(val:string())
		end,
		List	= function()
			local op = eval(val:first(), env)
			
			local lst = val:rest()
			
			if type(op) == 'Fexpr' then
				return op(env, Seq.lib.unpack(lst))
			elseif type(op) == 'Macro' then
				return eval(op(env, Seq.lib.unpack(lst)), env)
			elseif type(op) == 'function' then
				lst = Seq.lib.map(function(x) return eval(x, env) end, lst)
				return op(Seq.lib.unpack(lst))
			elseif type(op) == 'table'
			or (type(op) == 'userdata' and getmetatable(op).__index)
			then
				local key = eval(lst:first(), env)
				return op[key]
			else
				print ('attempt to apply non-function: '..op)
			end
			
			print ('undefined function: '..op)
			return nil
		end
	}
	
	local evaluator = switch[typ]
	if not evaluator then
		print ('Unknown type: '..typ)
		return nil
	end
	return evaluator()
end
