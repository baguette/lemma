
require 'expr'
require 'eval'

function times(n, f, ...)
   for i = 1, n do
      f(...)
   end
end

local fname = ...
local f, prompt
local done = false
local count = 0
local env = { prn = print, times = times }

if fname then
   f = io.open(fname, 'r')
   prompt = nil
else
   f = io.input()
   prompt = '> '
end

while not done do
   if prompt then io.write(prompt) end
   
   local t, c, e = expr(f)          -- read an expression!
   count = count + c
   
   if t then
      if t == 'eof' then
         done = true
      else
         local val = eval(t, env)   -- evaluate the expression!
         print (val)                -- print the value!
      end
   else
      print (count .. ': ' .. e)
   end
end                                 -- loop!
