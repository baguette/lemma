--
-- The Lemma REPL
--

-- TODO: implement a writer
-- TODO: more special forms
-- TODO: implement macros
-- TODO: more refactoring? (particularly in env.lua)

require 'stream'
require 'read'
require 'eval'
require 'env'

local fname = ...
local f, prompt
local done = false
local count = 0

if fname then
   f = io.open(fname, 'r')
   prompt = nil
else
   f = io.input()
   prompt = '> '
end

f = stream(f)

while not done do
   if prompt then io.write(prompt) end
   
   local t, e = read(f)                   -- read an expression!
   
   if t then
      if t == 'eof' then
         done = true
      else
         local val = eval(t, env)         -- evaluate the expression!
         if prompt then print (val) end   -- print the value!
      end
   else
      print (f:lines() .. ': ' .. e)
      done = true
   end
end                                       -- loop!
