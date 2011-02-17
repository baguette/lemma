
local symbol =          -- this is perhaps a little permissive
[[^([%a%-%?%*%+%%%$%^<>/\_=~:&|!][%a%d%-%?%*%+%%%$%^<>/\_=~:&|!@']*)]]

-- these are tried in undefined order (make specific!)
local atoms = {
   ['^(%()']            = 'open',
   ['^(%))']            = 'close',
   ['^(".-")']          = 'string', -- strings cannot be escaped yet
   ['^([%d%.]+)']       = 'number',
   ['^(#\\[^%s%(%)]+)'] = 'character',
   ['^(\')']            = 'quote',
   ['^(`)']             = 'quasiquote',
   ['^(,)']             = 'unquote',
   ['^(@)']             = 'splice',
   ['^(;.-)$']          = 'comment',
   ['^(#|)']            = 'opencomment',
   ['^(|#)']            = 'closecomment',
   ['^(#;)']            = 'datumcomment',
   [symbol]             = 'symbol'
}

local whitespace = '^([%s\n]+)'

function tokens(str)
   local t = {}
   local n

   len = string.len(str)
   n = 1
   
   -- should probably watch out for unmatched tokens...
   -- (loops forever on trailing newline, probably other tokens too)
   while n < len do
      local oldn = n
      
      local i, j, c = string.find(str, whitespace, n)   -- eat spaces
      if c then n = j + 1 end
   
      for k, v in pairs(atoms) do
         local i, j, c = string.find(str, k, n)
         if c then
            print ('match:', c, v)
            table.insert(t, c)    -- save {c, v} in here after testing is done
            n = j + 1
         end
      end
      
      if n == oldn then
         return nil, 'lexical error: '.. string.sub(str, n)
      end
   end
   
   return t
end

local fname = ...
local f = io.open(fname, 'r')

local count = 0
for line in f:lines() do
   local t, e = tokens(line)
   count = count + 1

   print "--- TEST ---"
   if t then
      print (table.concat(t, ' '))
   else
      print (count .. ': ' .. e)
   end
   print "------------"
end
