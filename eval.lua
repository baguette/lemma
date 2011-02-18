
function eval(t, env)
   local val, typ
   
   val = t[1]
   typ = t[2]
   
   local switch = {
      number = function() return val end,
      string = function() return val end,
      symbol = function() return env[val] end,  -- todo: lexical scope
      list   = function()                       -- todo: type checking
         local op = eval(val[1], env)           -- should be a function
         local lst = {}
         local i = 2
         
         for i = 2, #val do
            table.insert(lst, eval(val[i], env))
         end
         
         return op(unpack(lst))
      end
   }
   
   return switch[typ]()
end
