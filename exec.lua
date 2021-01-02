
lemma = {}
---
-- This table stores any metadata associated with a particular object.
-- It uses weak keys so that the metadata will be garbage collected if
-- the associated object is garbage collected.
---
lemma['*metadata*'] = {}
setmetatable(lemma['*metadata*'], { __mode = 'k' })



require 'class/FileStream'
require 'read'
require 'eval'
require 'compiled/std'
require 'compiled/compile'
require 'env'
require 'type'


---
-- Execute file f in the global environment.
-- If prompt is not nil, f should be stdin; starts a REPL.
---
function exec(f)
	local done = false
	
	if lemma.type(f) == 'string' then
		f, msg = io.open(f, 'r')
		if not f then
			error(msg)
		end
		prompt = nil
	end
	if lemma.type(f) ~= 'FileStream' then
		f = FileStream(f)
	end
	lemma['*in-stream*'] = f

	while not done do
		if prompt then io.write(prompt) end
		
		local t = read(f, true)                   -- read an expression!
		
		if lemma.type(t) ~= 'Error' then
			local blarg = Vector(pcall(eval, t, env))
			local good = blarg(1)
			local err = false
			if not good then
				io.stderr:write (f:lines() .. ': ' .. tostring(blarg(2)) .. '\n')
				err = true
			end
			                                      -- evaluate the expression!
			local val = Vector(select(2, Seq.lib.unpack(blarg)))
			
			for i = 1, val:length() do
				v = val[i]
				if v == Error'eof' then
					done = true
					f:close()
					return
				end
			end
			if prompt and not err then
				io.write';=> ' ; write(Seq.lib.unpack(val)) -- print the value!
			end 
		else
			if t == Error'eof' then
				if prompt then io.write('\n') end
				done = true
				f:close()
				return
			else
				io.stderr:write (f:lines() .. ': ' .. t:string() .. '\n')
				if not prompt then
					done = true
					f:close()
				end
			end
		end
	end                                           -- loop!
end

