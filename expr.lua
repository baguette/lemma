
local symbol =          -- this is perhaps a little permissive
[[^([%a%-%?%*%+%%%$%^<>/\_=~:&|!][%a%d%-%?%*%+%%%$%^<>/\_=~:&|!@']*)]]

local stringp = '^(".-")'

-- these are tried in undefined order (make specific!)
local atoms = {
   ['^(%()']            = 'open',
   ['^(%))']            = 'close',
   [stringp]            = 'string',
   ['^([%+%-]?%d+%.?%d+)']     = 'number',   -- with decimal point
   ['^([%+%-]?%d+)']    = 'number',          -- without decimal point
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

function treeify(t)
   local refs = {}
   local ref
   local parens = 0
   
   for i, v in ipairs(t) do
      if v[2] == 'open' then
         local next = {{}, 'list'}
         if ref then
            table.insert(ref[1], next)
            table.insert(refs, ref)
         end
         ref = next
         parens = parens + 1
      elseif v[2] == 'close' then
         if #refs > 0 then            -- don't pop if the stack is empty
            ref = table.remove(refs)
         end
         parens = parens - 1
      else
         if parens > 0 then         -- BUG HERE?
            table.insert(ref[1], v)
         else
            return v    -- add quote handling here?
         end
      end
   end
--[[
   for i, v in ipairs(ref[1]) do
      print ('|', v[1])
   end
--]]
   return ref
end

function expr(f)    -- read one expression from f, nil on error, 'eof' on eof
   local parens = 0
   local comments = 0
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
                 c = tonumber(c)
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
              elseif v == 'opencomment' then
                 comments = comments + 1
              elseif v == 'closecomment' then
                 comments = comments - 1
              end
              
              if v ~= 'comment' then
                 table.insert(t, {c, v})
              end
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
   
   return treeify(t), lines, 'comment'
end
