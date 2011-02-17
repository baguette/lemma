
-------------------
-- NOTE
--
-- I might be on to something here, but I need to think this
-- through before I keep coding...
-------------------



-- Arc's mutable lists represented as a Lua table t where
-- t[1] is a cursor and t[2] is the actual list.
-- Then, t[2][t[1]] is the car while the cdr is the same
-- list with t[1] = t[1] + 1.
-- The s function takes a Lua table and returns a cursored list.

function s (t)
   return {0, t}
end

function car (t)
   return t[2][t[1]]
end

function cdr (t)
   return {t[1] + 1, t[2]}
end

function s_table (t)
   local lst = {}
   for i = t[1], #(t[2]) do
      table.insert(lst, t[2][i])
   end
   return lst
end


-- Symbols are represented as strings stored in an object.
-- Thus, symbols are distinguishable from strings.
-- The q function takes a string and returns a symbol.

_LARC_SYMBOLS = {}

function q (str)
   local sym = _LARC_SYMBOLS[str]
   if sym then
      return sym
   else
      sym = {'q', str}
      _LARC_SYMBOLS[str] = sym
      return sym
   end
end

function isquote (x)
   return (x[1] == 'q')
end

function tolua (sym)          -- this should be recursive
   local t = type (sym)
   
   if t == 'table' then
      if isquote(sym)
         return sym[2]
      else                    -- assume it's a list...
         return s_table(sym)
      end
   elseif ty == 'string'
   or     ty == 'number' then
      return sym
   else
      return nil, 'unable to intern symbol'
   end
end


function eval (x)             -- eval needs to work for all types beside lists
   local t = type (x)
   
   if t == 'table' then
      local xcar = car (x)
      local lcar = s_table (xcar)
      if isquote(xcar) then
         local func = _LARC_SYMTAB[lcar]
         if func then
            local args = tolua(cdr (x))
            for i, v in ipairs(args) do
               args[i] = tolua(v)
            end
            
            return func (eval (cdr (x)))
         else
            return nil, 'error: attempt to call non-function ' .. lcar
         end
      end
   else
      return tolua(x)
   end
end

_LARC_SYMTAB['='] = function (t)
   _LARC_SYMTAB[t[1]] = t[2]
end

_[]

eval (s{q'=', q'hello', s{q'fn', s{}, q'prn', 'hello world!'}})



