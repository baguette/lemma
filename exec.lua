
lemma = {}

require 'class/FileStream'
require 'read'
require 'eval'
require 'env'
require 'type'


---
-- Load the standard library
---
function stdlib()
	local base = os.getenv('LEMMA_PATH') or '.'
	local lib = io.open(base..'/lib/std.lma', 'r')
	if lib then
		exec(lib)
	else
		io.write
[[
Error: unable to open standard library std.lma
Check that the LEMMA_PATH environment variable
print 'is set to the base path of the lemma directory.
]]
		os.exit(1)
	end
end

---
-- Execute file f in the global environment.
-- If prompt is not nil, f should be stdin; starts a REPL.
---
function exec(f)
	local done = false
	
	if type(f) == 'string' then
		f = io.open(f, 'r')
		prompt = nil
	end
	
	f = FileStream(f)

	while not done do
		if prompt then io.write(prompt) end
	
		local t, e = read(f)                       -- read an expression!
	
		if not e then
			if t == 'eof' then
				if prompt then io.write('\n') end
				done = true
				f:close()
			else
--				print (f:lines())
				local val = {eval(t, env)}           -- evaluate the expression!
				local err = false
				
				for i, v in ipairs(val) do
					if type(v) == 'Error' then
						io.stderr:write (f:lines() .. ': ' .. tostring(v) .. '\n')
						err = true
					end
				end
				if prompt and not err then
					io.write';=> ' ; write(unpack(val))                -- print the value!
				end
			end
		else
			io.stderr:write (f:lines() .. ': ' .. e .. '\n')
			if not prompt then
				done = true
				f:close()
			end
		end
	end                                           -- loop!
end
