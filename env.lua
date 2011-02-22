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

(function(t)
   for k, v in pairs(t) do
      _G[k] = {v, 'fexpr'}
   end
end)({
   def = function (env, ...)
      local args = {...}
      local i = 1
   
      while i <= #args do
         local v = args[i + 1]
         env:insert(args[i][1], eval(v, env))
         i = i + 2
      end
   
      return nil
   end,

   quote = function(env, ...)
      return ...
   end,
   
   ['if'] = function(env, ...)
      local args = {...}
      local test = eval(args[1], env)
      local expr = args[3]
      
      if test then
         expr = args[2]
      end
      
      return eval(expr, env)
   end,

   ['do'] = function(env, ...)     -- this will eventually become let
      local exps = {...}
      local val
   
      local env = env:enter()
      
      for i = 1, #exps do
         val = eval(exps[i], env)
      end
   
      return val
   end,
   
   fn = function(env, ...)
      local args = {...}
      local arglist = args[1][1]
      
      return function(...)
         local largs = {...}
         local env = env:enter()
         local val
         
         for i = 1, #arglist do
            env:insert(arglist[i][1], largs[i])
         end
         
         for i = 2, #args do
            val = eval(args[i], env)
         end
         
         return val
      end
   end,

   times = function(env, n, expr)
      local val
      local n = eval(n, env)
   
      for i = 1, n do
         val = eval(expr, env)
      end
      return val
   end
})


_G['+'] = function(...)
   local sum = 0
   
   for i, v in ipairs{...} do
      sum = sum + v
   end
   
   return sum
end

_G['-'] = function(...)
   local args = {...}
   local diff = args[1] or 0
   
   for i = 2, #args do
      diff = diff - args[i]
   end
   
   return diff
end

_G['*'] = function(...)
   local a, b = ...
   return (a * b)
end

_G['>'] = function(...)
   local a, b = ...
   return (a > b)
end

_G['='] = function(...)
   local a, b = ...
   return (a == b)
end

function new_env(env)
   local b
   if env then b = {} else b = _G end
   return {
      bindings = b,
      parent = env,      -- for implementing lexical scope
      lookup = function(self, sym)
         local curr = self
         while curr do
            local val = curr.bindings[sym]
            if val then
               return val
            end
            curr = curr.parent
         end
      end,
      insert = function(self, sym, val)
         self.bindings[sym] = val
      end,
      enter = new_env,
      leave = function(self)
         if self.parent then
            self.bindings = self.parent.bindings
            self.parent = self.parent.parent
         end
      end
   }
end

env = new_env()
