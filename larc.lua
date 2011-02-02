
tokenizer = require 'tokens'

-- The first and only argument is the file to open
local fname = ...
local f = io.open (fname, 'r')

local count = 0

local t, e = tokenizer.tokens (line)

if t then
   for _, tok in ipairs (t) do
      io.write (tok.lex .. '\t')
      io.write (tok.tok .. '\n')
   end
else
   print (count .. ': ' .. e)
end
