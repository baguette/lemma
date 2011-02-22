--
-- The Lemma Evaluator
--

function eval(t, env)
   local val, typ
   
   val = t[1]
   typ = t[2]
   
   local switch = {
      number = function() return val end,
      string = function() return val end,
      symbol = function()
         for k, v in pairs(env) do
            if v[val] then
               return v[val]
            end
         end
         return nil
      end,                                      -- todo: lexical scope
      list   = function()                       -- todo: type checking
         local op = val[1][1]
         local ev = env.expr[op] or env.subr[op]
         local fx = env.fexpr[op] or env.fsubr[op]
         local mo = env.macro[op]
         
         local lst = {}
         local i = 2
         
         if fx then
            for i = 2, #val do
               table.insert(lst, val[i])
            end
            return fx(env, unpack(lst))
         elseif ev then
            for i = 2, #val do
               local v = eval(val[i], env)
               table.insert(lst, v)
            end
            return ev(unpack(lst))
         elseif mo then
            return mo[val](unpack(lst))
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
