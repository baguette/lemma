
require 'expr'

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
   
   local t, c, e = expr(f)
   count = count + c
   
   if t then
      if t == 'eof' then
         done = true
      else
         for i, v in ipairs(t) do
            t[i] = table.concat(v, ':')
         end
         print (table.concat(t, ' '))
      end
   else
      print (count .. ': ' .. e)
   end
end
