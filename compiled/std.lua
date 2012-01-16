-- Lemma 0.2 --
_G["lemma"]["defmacro"] = Macro(function(_L1_0, _L1_1, ...)
local _L1_2 = List(...);
return _G["lua"]["List"](Symbol("def"), _L1_0, (function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_L1_2));
gel = lemma.unsplice(gel, _L1_1);
gel = lemma.unsplice(gel, Symbol("macro"));
return _G["lua"]["List"](lemma.splice(gel))
end)())
end);

_G["lemma"]["defn"] = Macro(function(_L1_0, _L1_1, ...)
local _L1_2 = List(...);
return _G["lua"]["List"](Symbol("def"), _L1_0, (function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_L1_2));
gel = lemma.unsplice(gel, _L1_1);
gel = lemma.unsplice(gel, Symbol("fn"));
return _G["lua"]["List"](lemma.splice(gel))
end)())
end);

_G["lemma"]["do"] = Macro(function(...)
local _L1_0 = List(...);
return _G["lua"]["List"]((function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_L1_0));
gel = lemma.unsplice(gel, Vector());
gel = lemma.unsplice(gel, Symbol("fn"));
return _G["lua"]["List"](lemma.splice(gel))
end)())
end);

_G["lemma"]["if"] = Macro(function(_L1_0, _L1_1, _L1_2)
return _G["lua"]["List"](Symbol("cond"), _L1_0, _L1_1, true, _L1_2)
end);

_G["lemma"]["when"] = Macro(function(_L1_0, ...)
local _L1_1 = List(...);
return _G["lua"]["List"](Symbol("cond"), _L1_0, (function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_L1_1));
gel = lemma.unsplice(gel, Symbol("do"));
return _G["lua"]["List"](lemma.splice(gel))
end)(), true, nil)
end);

_G["lemma"]["second"] = (function(_L1_0)
return _G["lemma"]["first"](_G["lemma"]["rest"](_L1_0))
end);

_G["lemma"]["odds"] = (function(_L1_0)
return (function()
if (_G["lemma"]["empty?"](_L1_0)) then
return _G["lemma"]["seq"](_L1_0)
elseif (true) then
return _G["lemma"]["cons"](_G["lemma"]["first"](_L1_0), _G["lemma"]["odds"](_G["lemma"]["rest"](_G["lemma"]["rest"](_L1_0))))
end
end)()

end);

_G["lemma"]["evens"] = (function(_L1_0)
return (function()
if ((_G["lemma"]["empty?"](_L1_0) or _G["lemma"]["="](1, _G["lemma"]["length"](_L1_0)))) then
return _G["lemma"]["seq"](_L1_0)
elseif (true) then
return _G["lemma"]["cons"](_G["lemma"]["first"](_G["lemma"]["rest"](_L1_0)), _G["lemma"]["evens"](_G["lemma"]["rest"](_G["lemma"]["rest"](_L1_0))))
end
end)()

end);

_G["lemma"]["let"] = Macro(function(_L1_0, ...)
local _L1_1 = List(...);
return (function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_G["lemma"]["evens"](_L1_0)));
gel = lemma.unsplice(gel, (function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_L1_1));
gel = lemma.unsplice(gel, _G["lemma"]["odds"](_L1_0));
gel = lemma.unsplice(gel, Symbol("fn"));
return _G["lua"]["List"](lemma.splice(gel))
end)());
return _G["lua"]["List"](lemma.splice(gel))
end)()
end);

_G["lemma"]["loop"] = Macro(function(_L1_0, ...)
local _L1_1 = List(...);
return _G["lua"]["List"](Symbol("do"), (function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_L1_1));
gel = lemma.unsplice(gel, _G["lemma"]["odds"](_L1_0));
gel = lemma.unsplice(gel, Symbol("recur"));
gel = lemma.unsplice(gel, Symbol("defn"));
return _G["lua"]["List"](lemma.splice(gel))
end)(), (function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_G["lemma"]["evens"](_L1_0)));
gel = lemma.unsplice(gel, Symbol("recur"));
return _G["lua"]["List"](lemma.splice(gel))
end)())
end);

_G["lemma"]["let-if"] = Macro(function(_L1_0, _L1_1, _L1_2)
return (function(_L2_0, _L2_1)
return _G["lua"]["List"](_G["lua"]["List"](Symbol("fn"), Vector(_L2_0), _G["lua"]["List"](Symbol("if"), _L2_0, _L1_1, _L1_2)), _L2_1)
end)(_G["lemma"]["first"](_L1_0), _G["lemma"]["second"](_L1_0))
end);

_G["lemma"]["let-values"] = Macro(function(_L1_0, ...)
local _L1_1 = List(...);
return _G["lua"]["List"]((function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_G["lemma"]["rest"](_L1_1)));
gel = lemma.unsplice(gel, _L1_0);
gel = lemma.unsplice(gel, Symbol("fn"));
return _G["lua"]["List"](lemma.splice(gel))
end)(), _G["lemma"]["first"](_L1_1))
end);

_G["lemma"]["times"] = Macro(function(_L1_0, ...)
local _L1_1 = List(...);
return _G["lua"]["List"](Symbol("do"), _G["lua"]["List"](Symbol("defn"), Symbol("once"), Vector(Symbol("i")), _G["lua"]["List"](Symbol("if"), _G["lua"]["List"](Symbol("="), Symbol("i"), 2), (function()
local gel = List();
gel = lemma.unsplice(gel, true);
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_L1_1));
gel = lemma.unsplice(gel, Symbol("do"));
return _G["lua"]["List"](lemma.splice(gel))
end)(), (function()
local gel = List();
gel = lemma.unsplice(gel, _G["lua"]["List"](Symbol("once"), _G["lua"]["List"](Symbol("-"), Symbol("i"), 1)));
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_L1_1));
gel = lemma.unsplice(gel, Symbol("do"));
return _G["lua"]["List"](lemma.splice(gel))
end)())), _G["lua"]["List"](Symbol("once"), _L1_0))
end);

(function(_L1_0)
return _G["lemma"]["for-each"]((function(_L2_0)
return (function(_L3_0)
return _G["lemma"]["table-set!"](_G["lua"]["lemma"], _L3_0, (function(_L4_0)
return _G["lemma"]["="](_G["lua"]["type"](_L4_0), _L2_0)
end))
end)(_G["lemma"]["str"](_G["lemma"]["method"]("lower")(_L2_0), "?"))
end), _L1_0)
end)(Vector("Vector", "HashMap", "List", "Symbol", "Macro", "Fexpr", "function", "string"))
_G["lemma"]["mapstr"] = (function(_L1_0, _L1_1, _L1_2)
_L1_2 = (function()
if (_G["lemma"]["="](_L1_2, nil)) then
return ""
elseif (true) then
return _L1_2
end
end)()
;
return (function(_L2_0)
return _G["lua"]["string"]["sub"]((function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_L2_0));
return _G["lemma"]["str"](lemma.splice(gel))
end)(), 1, _G["lemma"]["-"](-1, _G["lemma"]["length"](_L1_2)))
end)(_G["lemma"]["map"]((function(_L2_0)
return _G["lemma"]["str"](_L1_0(_L2_0), _L1_2)
end), _L1_1))
end);

_G["lemma"]["defmethod"] = Macro(function(_L1_0, _L1_1, ...)
local _L1_2 = List(...);
return (function()
if (_G["lemma"]["not"](_G["lemma"]["vector?"](_L1_1))) then
return _G["lua"]["Error"](_G["lemma"]["str"]("defmethod: expected vector, got ", _G["lua"]["tostring"](_L1_1), " : ", _G["lua"]["type"](_L1_1)))
elseif (true) then
return (function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_L1_2));
gel = lemma.unsplice(gel, Vector(Symbol("self"), _G["lemma"]["splice"](_L1_1)));
gel = lemma.unsplice(gel, _L1_0);
gel = lemma.unsplice(gel, Symbol("defn"));
return _G["lua"]["List"](lemma.splice(gel))
end)()
end
end)()

end);

_G["lemma"]["any?"] = (function(_L1_0, _L1_1)
return (function()
if (_G["lemma"]["empty?"](_L1_1)) then
return false
elseif (true) then
return (function(_L2_0)
return (function()
if (_L1_0(_L2_0)) then
return true
elseif (true) then
return _G["lemma"]["any?"](_L1_0, _G["lemma"]["rest"](_L1_1))
end
end)()

end)(_G["lemma"]["first"](_L1_1))
end
end)()

end);

_G["lemma"]["dump-meta"] = (function()
return _G["lua"]["loadstring"]("\
    for k, v in pairs(lemma['*metadata*']) do\
      for m, w in pairs(v) do\
        io.write(tostring(k)..': '..m..' =  '..w..'\\n')\
      end\
    end\
  ")()
end);

_G["lua"]["collectgarbage"]("collect")
-- EOF --
