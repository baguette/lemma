--
-- Lemma Environment
--

-- find sym in this environment
function lookup(env, sym)
   while env do
      local val = env.bindings[sym]
      if val then
         return val
      end
      env = env.parent
   end
end

function xdo(env, ...)     -- this will eventually become let
   local exps = {...}
   local val
   
   for i = 1, #exps do
      val = eval(exps[i], env)
   end
   
   return val
end

function times(env, n, expr)
   local val
   local n = eval(n, env)
   
   for i = 1, n do
      val = eval(expr, env)
   end
   return val
end

function add(...)
   local sum = 0
   
   for i, v in ipairs{...} do
      sum = sum + v
   end
   
   return sum
end

function sub(...)
   local args = {...}
   local diff = args[1] or 0
   
   for i = 2, #args do
      diff = diff - args[i]
   end
   
   return diff
end

function def(env, ...)
   local args = {...}
   local i = 1
   
   while i <= #args do
      local v = args[i + 1]
      env.expr[args[i][1]] = eval(v, env)
      i = i + 2
   end
   
   return nil
end


-- TODO: this could use a better representation...
env = {
   subr = {
      prn = print, ['+'] = add, ['-'] = sub
   },
   fsubr = {
      def = def, times = times, ['do'] = xdo
   },
   expr = {},
   fexpr = {},
   macro = {},
   parent = nil      -- for implementing lexical scope
}