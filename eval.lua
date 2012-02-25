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

---
-- This is just a workaround for circular module dependencies.
-- It will be replaced by the actual compile function before
-- it ever gets called.
---
lemma.compile = function(s) return "" end

function eval(t, env)
	local undefined = false
	
	if type(t) == 'List' then
		local h = t:first()
		if type(h) == 'Symbol' then
			local undef = string.sub(h:string(), 1, 3)
			if undef == 'def' or undef == 'set' or undef == 'ns' then
				undefined = true
			end
		end
	end
	
	local code = lemma.compile(t)
	if type(code) == 'Error' then
		return code
	end
	
	if not undefined then
		code = 'return '..code
	end
	
	if lemma['*debug*'] then
		print('------'..tostring(undefined))
		print(code)
		print '------'
	end
	
	local f, err = loadstring(code)
	if not f then
		return error('compiler error:    \n'..tostring(err))
	end
	
	local blarg = Vector(pcall(f))
	if not blarg(1) then
		return error('eval: '..tostring(blarg(2)))
	end
	return select(2, Seq.lib.unpack(blarg))
end

