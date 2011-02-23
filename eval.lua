--
-- The Lemma Evaluator
--

function eval(t, env)
   local val, typ
   
   val = t
   typ = type(t)
   
   if typ == 'table' then
      val = t[1]
      typ = t[2]
   end
   
   local switch = {
      number = function() return val end,
      string = function() return val end,
      symbol = function()
         return env:lookup(val)
      end,                                      -- todo: lexical scope
      list   = function()                       -- todo: type checking
         local op = val[1][1]
         
         op = env:lookup(op)
         
         local lst = {}
         local i = 2
         
         if type(op) == 'table' and op[2] == 'fexpr' then
            for i = 2, #val do
               table.insert(lst, val[i])
            end
            return op[1](env, unpack(lst))
         elseif type(op) == 'function' then
            for i = 2, #val do
               local v = eval(val[i], env)
               table.insert(lst, v)
            end
            return op(unpack(lst))
         else
            print ('attempt to apply non-function: '..op)
         end
         
         print ('undefined function: '..op)
         return nil
      end
   }
   
   local evaluator = switch[typ]
   if not evaluator then
      print ('Unknown type: '..typ)
   end
   return evaluator()
end
