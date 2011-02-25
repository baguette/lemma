---
-- The Lemma REPL
---

-- TODO: more special forms
-- TODO: redo the internal representations of lists as ADTs? (c.f. seqs)

require 'stream'
require 'read'
require 'eval'
require 'env'


---
-- Execute file f in the global environment.
-- If prompt is not nil, f should be stdin; starts a REPL.
---
function exec(f, prompt)
   local done = false
   local f = stream(f)

   while not done do
      if prompt then io.write(prompt) end
   
      local t, e = read(f)                   -- read an expression!
   
      if t then
         if t == 'eof' then
            done = true
         else
            local val = eval(t, env)         -- evaluate the expression!
            if prompt then
               write(val)                    -- print the value!
               io.write('\n')
            end
         end
      else
         print (f:lines() .. ': ' .. e)
         done = true
         f:close()
      end
   end                                       -- loop!
end

---
-- Load the standard library
---
local lib = io.open('lib.lma', 'r')
if lib then
   exec(lib)
else
   print 'Error: unable to open standard library lib.lma'
   os.exit(1)
end

---
-- Execute command line argument or start a REPL
---
local fname = ...
local f, prompt

if fname then
   f = io.open(fname, 'r')
   prompt = nil
else
   f = io.input()
   prompt = '> '
end

exec(f, prompt)
