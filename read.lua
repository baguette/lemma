---
-- The Lemma Reader
---

-- TODO: 'multidispatch' reader macro

---
-- Write an external representation of t to stdout
---
function write(t)
   if type(t) == 'table' then
      if t[2] == 'list' then
         io.write('(')
         for i, v in ipairs(t[1]) do
            write(v)
            if i < #t[1] then io.write(' ') end
         end
         io.write(')')
      else
         io.write(tostring(t[1]))
      end
   elseif type(t) == 'string' then
      io.write('"'..tostring(t)..'"')
   else
      io.write(tostring(t))
   end
end

local symbol =          -- this is perhaps a little too permissive
[[^([%a%-%?%*%+%%%$%^<>\\_=:&|!][%.%a%d%-%?%*%+%%%$%^<>/\\_=:&|!~@']*)]]

-- these are tried in undefined order (make them specific!)
local atoms = {
   ['^([%+%-]?%d+%.?%d+)']     = 'number',   -- with decimal point
   ['^([%+%-]?%d+)']           = 'number',   -- without decimal point
   [symbol]                    = 'symbol'
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
         return table.concat(str)
      elseif c == '\\' then
         escape = true
         if not c then return 'eof' end
      else
         escape = false
      end
      
      if not escape then
         table.insert(str, c)
      end
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

function read_quote(sym)
   return function(f)
      local q = {{}, 'list'}
      table.insert(q[1], {sym, 'symbol'})
      table.insert(q[1], read(f))
      return q
   end
end

function table_idx(func)
   return function(f)
      local idx = read(f)
      local t = read(f)
      return {{{func, 'symbol'}, t, idx[1]}, 'list'}
   end
end


local reader_macros = {
   ['(']             = read_list,
   ['"']             = read_string,
   ['.']             = table_idx('get'),
   [':']             = table_idx('method'),      -- like table_idx, but passes self
   ['\'']            = read_quote('quote'),
   ['`']             = read_quote('quasiquote'),
   ['~']             = read_quote('unquote'),
   ['@']             = read_quote('splice'),
   [';']             = read_comment,
   ['#']             = 'multidispatch'
}


---
-- Read the next form from stream f
---
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
                form = tonumber(str)
             else
                form = {str, typ}
             end
          end
      end
      
      if not form then
         return nil, 'lexical error on token: '..f:get()..str
      end
   end
   
   if form then
      return form
   end
   
   return read(f)
end
