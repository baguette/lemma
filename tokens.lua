M = {}

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

-- things to ignore
local whitespace = '^([%s\n]+)'


-- return a list of the tokens found in str
-- or (nil, errorstr) on lexical error
function M.tokens (str)
   local t = {}
   local n = 1
   local len = string.len (str)
   
   -- should probably watch out for unmatched tokens...
   -- (loops forever on trailing newline, probably other tokens too)
   while n <= len do
      local oldn = n
      
      local i, j, c = string.find (str, whitespace, n)     -- eat spaces
      if c then n = j + 1 end
   
      for k, v in pairs (atoms) do       -- try matching all the patterns
         local i, j, c = string.find (str, k, n)
         
         if c then
            n = j + 1
            table.insert (t, {lex = c, tok = v})   -- lexeme and token type
         end
      end
      
      if n == oldn then            -- if none of the patterns matched, error
         return nil, 'lexical error: '.. string.sub (str, n)
      end
   end
   
   return t
end

return M
