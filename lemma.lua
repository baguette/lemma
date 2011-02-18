
local symbol =          -- this is perhaps a little permissive
[[^([%a%-%?%*%+%%%$%^<>/\_=~:&|!][%a%d%-%?%*%+%%%$%^<>/\_=~:&|!@']*)]]

local stringp = '^(".-")'

-- these are tried in undefined order (make specific!)
local atoms = {
   ['^(%()']            = 'open',
   ['^(%))']            = 'close',
   ['^(\\)']            = 'backslash',
   [stringp]            = 'string',
   ['^([%d%.]+)']       = 'number',
   ['^(#\\[^%s%(%)]+)'] = 'character',
   ['^(\')']            = 'quote',
   ['^(`)']             = 'quasiquote',
   ['^(,)']             = 'unquote',
   ['^(@)']             = 'splice',
   ['^(;.-)$']          = 'comment',
   ['^(#|)']            = 'opencomment', -- comments cannot be nested yet
   ['^(|#)']            = 'closecomment',
   ['^(#;)']            = 'datumcomment',
   [symbol]             = 'symbol'
}

local whitespace = '^([%s\n]+)'

function expr(f)    -- read one expression from f, nil on error, 'eof' on eof
   local parens = 0
   local lines = 0
   local t = {}
   
   repeat
     local n = 1
     local str = f:read()   -- get one line at a time
     
     if not str then
        return 'eof', lines
     end
     
     local len = string.len(str)
     
     lines = lines + 1
     
     -- should probably watch out for unmatched tokens...
     -- (loops forever on trailing newline, probably other tokens too)
     while n <= len do
        local oldn = n
      
        local i, j, c = string.find(str, whitespace, n)   -- eat spaces
        if c then n = j + 1 end
      
        for k, v in pairs(atoms) do
           local i, j, c = string.find(str, k, n)
           if c then
              if v == 'open' then
                 parens = parens + 1
              elseif v == 'close' then
                 parens = parens - 1
              elseif v == 'number' then
                 c = c + 0          -- coerce c to a number value
              elseif v == 'string' then
                 local m = j
                 while string.sub(c, -2, -2) == '\\' do
                    local _, d
                    _, m, d = string.find(str, stringp, m)
                    if d then
                       c = c .. d
                    else
                       return nil, lines, 'error building string: '..c
                    end
                 end
                 j = m
                 c = string.sub(c, 2, -2)
                 c = string.gsub(c, '\\""', '"')          
              end
              table.insert(t, {c, v})
              n = j + 1
           end
        end
      
        if n == oldn then
           return nil, lines, 'lexical error: '.. string.sub(str, n)
        elseif parens < 0 then
           return nil, lines, 'unmatched ) paren: '
        end
     end
   until parens == 0

   return t, lines
end


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

local exps = 0
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
