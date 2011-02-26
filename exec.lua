
require 'class/FileStream'
require 'read'
require 'eval'
require 'env'


---
-- Load the standard library
---
function stdlib()
	local lib = io.open('lib.lma', 'r')
	if lib then
		exec(lib)
	else
		print 'Error: unable to open standard library lib.lma'
		os.exit(1)
	end
end

---
-- Execute file f in the global environment.
-- If prompt is not nil, f should be stdin; starts a REPL.
---
function exec(f, prompt)
	local done = false
	
	if type(f) == 'string' then
		f = io.open(f, 'r')
		prompt = nil
	end
	
	f = FileStream(f)

	while not done do
		if prompt then io.write(prompt) end
	
		local t, e = read(f)                       -- read an expression!
	
		if t then
			if t == 'eof' then
				print''
				done = true
				f:close()
			else
--				print (f:lines())
				local val = {eval(t, env)}           -- evaluate the expression!
				if prompt then
					write(unpack(val))                -- print the value!
				end
			end
		else
			print (f:lines() .. ': ' .. e)
			done = true
			f:close()
		end
	end                                           -- loop!
end
