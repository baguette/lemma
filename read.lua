--
-- The Lemma Reader
--

-- TODO: finish implementing reader macros


local symbol =          -- this is perhaps a little permissive
[[^([%a%-%?%*%+%%%$%^<>/\_=:&|!][%a%d%-%?%*%+%%%$%^<>/\_=:&|!@']*)]]

-- these are tried in undefined order (make specific!)
local atoms = {
   ['^([%+%-]?%d+%.?%d+)']     = 'number',   -- with decimal point
   ['^([%+%-]?%d+)']    = 'number',          -- without decimal point
   [symbol]             = 'symbol'
}

local number = {}
for i = 0, 9 do
   number[i] = true
end

local whitespace = {
   [' '] = true,
   ['\t'] = true,
   ['\n'] = true,
   [','] = true
}

local delim = {
   ['('] = true,
   [')'] = true
}

-- TODO: would probably be beneficial to make this tail-recursive
function read_list(f)
   local list = {}
   
   while true do
      local c = f:get()
      if not c then return 'eof' end
      
      if c == ')' then
         return {list, 'list'}
      else
         f:unget(c)
         local form = read(f)
         if form == 'eof' then return 'eof' end
         table.insert(list, form)
      end
   end
end

function read_string(f)
   local str = {}
   local escape = false
   
   while true do
      local c = f:get()
      if not c then return 'eof' end
      
      if c == '"' and not escape then
         return {table.concat(str), 'string'}
      elseif c == '\\' then
         escape = true
         c = f:get()
         if not c then return 'eof' end
      else
         escape = false
      end
      
      table.insert(str, c)
   end
end

function read_comment(f)
   local c
   repeat
      c = f:get()
      if not c then return 'eof' end
   until c == '\n'
   return nil
end

function read_quote(f)
   local q = {{}, 'list'}
   table.insert(q[1], {'quote', 'symbol'})
   table.insert(q[1], read(f))
   return q
end

-- TODO: replace the string values with handler functions
local reader_macros = {
   ['(']            = read_list,
   ['"']             = read_string,
   ['\'']            = read_quote,
   ['`']             = 'quasiquote',
   ['~']             = 'unquote',
   ['@']             = 'splice',
   [';']          = read_comment,
   ['#']            = 'multidispatch'
}

-- Read the next form from stream f
function read(f)
   local form = nil
   
   ---
   -- If it's not whitespace, and it's not a reader macro, then
   -- it's either a symbol or number.
   ---
   
   local c = f:get()
   if not c then return 'eof' end
   
   while whitespace[c] do
      c = f:get()
      if not c then return 'eof' end
   end
   
   local macro = reader_macros[c]
   
   if macro then
      form = macro(f)
   else
      local str = {}
      while not delim[c] and not whitespace[c] do
         table.insert(str, c)
         c = f:get()
         if not c then return 'eof' end      -- is this the right spot for this?
      end
      
      f:unget(c)
      str = table.concat(str)
      
      -- Do a pattern match on str to identify type of atom
      -- if no matches, lexical error
      for k, typ in pairs(atoms) do
          if string.find(str, k) then
             if typ == 'number' then
                str = tonumber(str)
             end
             
             form = {str, typ}
          end
      end
      
      if not form then
         return nil, 'lexical error ('..str..')'
      end
   end
   
   if form then
      return form
   end
   
   return read(f)
end
