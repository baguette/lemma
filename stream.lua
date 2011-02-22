-- A buffered stream of characters.
function stream(f)
   local buffer = {}
   local lines = 1
   
   return {
      get = function(self)
         local c
         if #buffer > 0 then
            c = table.remove(buffer)
         else
            c = f:read(1)
         end
         if c == '\n' or c == '\r' then
            lines = lines + 1
         end
         return c
      end,
      unget = function(self, c)
         if c == '\n' or c == '\r' then
            lines = lines - 1
         end
         table.insert(buffer, c)
      end,
      file = function(self) return f end,
      lines = function(self) return lines end
   }
end
