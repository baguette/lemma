
require 'expr'
require 'eval'

function xdo(env, ...)
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

local fname = ...
local f, prompt
local done = false
local count = 0
local env = {
   subr = {
      prn = print, ['+'] = add, ['-'] = sub
   },
   fsubr = {
      def = def, times = times, ['do'] = xdo
   },
   expr = {},
   fexpr = {},
   macro = {}
}

if fname then
   f = io.open(fname, 'r')
   prompt = nil
else
   f = io.input()
   prompt = '> '
end

while not done do
   if prompt then io.write(prompt) end
   
   local t, c, e = expr(f)                -- read an expression!
   count = count + c
   
   if t then
      if t == 'eof' then
         done = true
      else
         local val = eval(t, env)         -- evaluate the expression!
         if prompt then print (val) end   -- print the value!
      end
   else
      if e ~= 'comment' then
         print (count .. ': ' .. e)
      end
   end
end                                       -- loop!
