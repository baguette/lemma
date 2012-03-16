-- Lemma 0.2 --
lemma["defmacro"] = Macro(function(_L1_0, _L1_1, ...)
local _L1_2 = List(...);
return lemma["lua"]["List"](Symbol("def"), _L1_0, (function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](_L1_2));
gel = lemma.unsplice(gel, _L1_1);
gel = lemma.unsplice(gel, Symbol("macro"));
return lemma["lua"]["List"](lemma.splice(gel))
end)())
end);

lemma["defn"] = Macro(function(_L1_0, _L1_1, ...)
local _L1_2 = List(...);
return lemma["lua"]["List"](Symbol("def"), _L1_0, (function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](_L1_2));
gel = lemma.unsplice(gel, _L1_1);
gel = lemma.unsplice(gel, Symbol("fn"));
return lemma["lua"]["List"](lemma.splice(gel))
end)())
end);

lemma["do"] = Macro(function(...)
local _L1_0 = List(...);
return lemma["lua"]["List"]((function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](_L1_0));
gel = lemma.unsplice(gel, Vector());
gel = lemma.unsplice(gel, Symbol("fn"));
return lemma["lua"]["List"](lemma.splice(gel))
end)())
end);

lemma["if"] = Macro(function(_L1_0, _L1_1, _L1_2)
return lemma["lua"]["List"](Symbol("cond"), _L1_0, _L1_1, true, _L1_2)
end);

lemma["when"] = Macro(function(_L1_0, ...)
local _L1_1 = List(...);
return lemma["lua"]["List"](Symbol("cond"), _L1_0, (function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](_L1_1));
gel = lemma.unsplice(gel, Symbol("do"));
return lemma["lua"]["List"](lemma.splice(gel))
end)(), true, nil)
end);

lemma["second"] = (function(_L1_0)
return lemma["first"](lemma["rest"](_L1_0))
end);

lemma["odds"] = (function(_L1_0)
return (function()
if (lemma["empty?"](_L1_0)) then
return lemma["seq"](_L1_0)
elseif (true) then
return lemma["cons"](lemma["first"](_L1_0), lemma["odds"](lemma["rest"](lemma["rest"](_L1_0))))
end
end)()

end);

lemma["evens"] = (function(_L1_0)
return (function()
if ((lemma["empty?"](_L1_0) or lemma["="](1, lemma["length"](_L1_0)))) then
return lemma["seq"](_L1_0)
elseif (true) then
return lemma["cons"](lemma["first"](lemma["rest"](_L1_0)), lemma["evens"](lemma["rest"](lemma["rest"](_L1_0))))
end
end)()

end);

lemma["let"] = Macro(function(_L1_0, ...)
local _L1_1 = List(...);
return (function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](lemma["evens"](_L1_0)));
gel = lemma.unsplice(gel, (function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](_L1_1));
gel = lemma.unsplice(gel, lemma["odds"](_L1_0));
gel = lemma.unsplice(gel, Symbol("fn"));
return lemma["lua"]["List"](lemma.splice(gel))
end)());
return lemma["lua"]["List"](lemma.splice(gel))
end)()
end);

lemma["loop"] = Macro(function(_L1_0, ...)
local _L1_1 = List(...);
return lemma["lua"]["List"](Symbol("do"), (function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](_L1_1));
gel = lemma.unsplice(gel, lemma["odds"](_L1_0));
gel = lemma.unsplice(gel, Symbol("recur"));
gel = lemma.unsplice(gel, Symbol("defn"));
return lemma["lua"]["List"](lemma.splice(gel))
end)(), (function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](lemma["evens"](_L1_0)));
gel = lemma.unsplice(gel, Symbol("recur"));
return lemma["lua"]["List"](lemma.splice(gel))
end)())
end);

lemma["let-if"] = Macro(function(_L1_0, _L1_1, _L1_2)
return (function(_L2_0, _L2_1)
return lemma["lua"]["List"](lemma["lua"]["List"](Symbol("fn"), Vector(_L2_0), lemma["lua"]["List"](Symbol("if"), _L2_0, _L1_1, _L1_2)), _L2_1)
end)(lemma["first"](_L1_0), lemma["second"](_L1_0))
end);

lemma["let-values"] = Macro(function(_L1_0, ...)
local _L1_1 = List(...);
return lemma["lua"]["List"]((function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](lemma["rest"](_L1_1)));
gel = lemma.unsplice(gel, _L1_0);
gel = lemma.unsplice(gel, Symbol("fn"));
return lemma["lua"]["List"](lemma.splice(gel))
end)(), lemma["first"](_L1_1))
end);

lemma["times"] = Macro(function(_L1_0, ...)
local _L1_1 = List(...);
return lemma["lua"]["List"](Symbol("do"), lemma["lua"]["List"](Symbol("defn"), Symbol("once"), Vector(Symbol("i")), lemma["lua"]["List"](Symbol("if"), lemma["lua"]["List"](Symbol("="), Symbol("i"), 2), (function()
local gel = List();
gel = lemma.unsplice(gel, true);
gel = lemma.unsplice(gel, lemma["splice"](_L1_1));
gel = lemma.unsplice(gel, Symbol("do"));
return lemma["lua"]["List"](lemma.splice(gel))
end)(), (function()
local gel = List();
gel = lemma.unsplice(gel, lemma["lua"]["List"](Symbol("once"), lemma["lua"]["List"](Symbol("-"), Symbol("i"), 1)));
gel = lemma.unsplice(gel, lemma["splice"](_L1_1));
gel = lemma.unsplice(gel, Symbol("do"));
return lemma["lua"]["List"](lemma.splice(gel))
end)())), lemma["lua"]["List"](Symbol("once"), _L1_0))
end);

(function(_L1_0)
return lemma["for-each"]((function(_L2_0)
return (function(_L3_0)
return lemma["table-set!"](lemma["lua"]["lemma"], _L3_0, (function(_L4_0)
return lemma["="](lemma["lua"]["type"](_L4_0), _L2_0)
end))
end)(lemma["str"](lemma["method"]("lower")(_L2_0), "?"))
end), _L1_0)
end)(Vector("Vector", "HashMap", "List", "Symbol", "Macro", "Fexpr", "function", "string"))
lemma["mapstr"] = (function(_L1_0, _L1_1, _L1_2)
_L1_2 = (function()
if (lemma["="](_L1_2, nil)) then
return ""
elseif (true) then
return _L1_2
end
end)()
;
return (function(_L2_0)
return lemma["lua"]["string"]["sub"]((function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](_L2_0));
return lemma["str"](lemma.splice(gel))
end)(), 1, lemma["-"](-1, lemma["length"](_L1_2)))
end)(lemma["map"]((function(_L2_0)
return lemma["str"](_L1_0(_L2_0), _L1_2)
end), _L1_1))
end);

lemma["defmethod"] = Macro(function(_L1_0, _L1_1, ...)
local _L1_2 = List(...);
return (function()
if (lemma["not"](lemma["vector?"](_L1_1))) then
return lemma["lua"]["Error"](lemma["str"]("defmethod: expected vector, got ", lemma["lua"]["tostring"](_L1_1), " : ", lemma["lua"]["type"](_L1_1)))
elseif (true) then
return (function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](_L1_2));
gel = lemma.unsplice(gel, Vector(Symbol("self"), lemma["splice"](_L1_1)));
gel = lemma.unsplice(gel, _L1_0);
gel = lemma.unsplice(gel, Symbol("defn"));
return lemma["lua"]["List"](lemma.splice(gel))
end)()
end
end)()

end);

lemma["any?"] = (function(_L1_0, _L1_1)
return (function()
if (lemma["empty?"](_L1_1)) then
return false
elseif (true) then
return (function(_L2_0)
return (function()
if (_L1_0(_L2_0)) then
return true
elseif (true) then
return lemma["any?"](_L1_0, lemma["rest"](_L1_1))
end
end)()

end)(lemma["first"](_L1_1))
end
end)()

end);

lemma["dump-meta"] = (function()
return lemma["lua"]["loadstring"]("\
    for k, v in pairs(lemma['*metadata*']) do\
      for m, w in pairs(v) do\
        io.write(tostring(k)..': '..m..' =  '..w..'\\n')\
      end\
    end\
  ")()
end);

lemma["lua"]["collectgarbage"]("collect")
-- EOF --
