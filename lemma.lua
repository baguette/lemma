--
-- The Lemma REPL
--

-- TODO: lexical scope
-- TODO: more special forms
-- TODO: macros

require 'expr'
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

while not done do
   if prompt then io.write(prompt) end
   
   local t, c, e = expr(f)                -- read an expression!
   count = count + c
   
   if t then
      if t == 'eof' then
         done = true
      else
         local val = eval(t, env)         -- evaluate the expression!
         if prompt then print (val) end   -- print the value!
      end
   else
      if e ~= 'comment' then
         print (count .. ': ' .. e)
      end
   end
end                                       -- loop!
