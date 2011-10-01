-- Lemma 0.2 --
_NS["lemma"]["defmacro"] = Macro(function(_LG1_0, _LG1_1, ...)
local _LG1_2 = List(...);
return _NS["lua"]["List"](Symbol("def"), _LG1_0, (function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_LG1_2));
gel = lemma.unsplice(gel, _LG1_1);
gel = lemma.unsplice(gel, Symbol("macro"));
return _NS["lua"]["List"](lemma.splice(gel))
end)())
end);

_NS["lemma"]["defn"] = Macro(function(_LG1_0, _LG1_1, ...)
local _LG1_2 = List(...);
return _NS["lua"]["List"](Symbol("def"), _LG1_0, (function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_LG1_2));
gel = lemma.unsplice(gel, _LG1_1);
gel = lemma.unsplice(gel, Symbol("fn"));
return _NS["lua"]["List"](lemma.splice(gel))
end)())
end);

_NS["lemma"]["do"] = Macro(function(...)
local _LG1_0 = List(...);
return _NS["lua"]["List"]((function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_LG1_0));
gel = lemma.unsplice(gel, Vector());
gel = lemma.unsplice(gel, Symbol("fn"));
return _NS["lua"]["List"](lemma.splice(gel))
end)())
end);

_NS["lemma"]["if"] = Macro(function(_LG1_0, _LG1_1, _LG1_2)
return _NS["lua"]["List"](Symbol("cond"), _LG1_0, _LG1_1, true, _LG1_2)
end);

_NS["lemma"]["when"] = Macro(function(_LG1_0, ...)
local _LG1_1 = List(...);
return _NS["lua"]["List"](Symbol("cond"), _LG1_0, (function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_LG1_1));
gel = lemma.unsplice(gel, Symbol("do"));
return _NS["lua"]["List"](lemma.splice(gel))
end)(), true)
end);

_NS["lemma"]["second"] = (function(_LG1_0)
return _NS["lemma"]["first"](_NS["lemma"]["rest"](_LG1_0));

end);

_NS["lemma"]["odds"] = (function(_LG1_0)
return (function()
if (_NS["lemma"]["empty?"](_LG1_0)) then
return _NS["lemma"]["seq"](_LG1_0)
elseif (true) then
return _NS["lemma"]["cons"](_NS["lemma"]["first"](_LG1_0), _NS["lemma"]["odds"](_NS["lemma"]["rest"](_NS["lemma"]["rest"](_LG1_0))))
end
end)()

end);

_NS["lemma"]["evens"] = (function(_LG1_0)
return (function()
if ((_NS["lemma"]["empty?"](_LG1_0) or _NS["lemma"]["="](1, _NS["lemma"]["length"](_LG1_0)))) then
return _NS["lemma"]["seq"](_LG1_0)
elseif (true) then
return _NS["lemma"]["cons"](_NS["lemma"]["first"](_NS["lemma"]["rest"](_LG1_0)), _NS["lemma"]["evens"](_NS["lemma"]["rest"](_NS["lemma"]["rest"](_LG1_0))))
end
end)()

end);

_NS["lemma"]["let"] = Macro(function(_LG1_0, ...)
local _LG1_1 = List(...);
return (function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_NS["lemma"]["evens"](_LG1_0)));
gel = lemma.unsplice(gel, (function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_LG1_1));
gel = lemma.unsplice(gel, _NS["lemma"]["odds"](_LG1_0));
gel = lemma.unsplice(gel, Symbol("fn"));
return _NS["lua"]["List"](lemma.splice(gel))
end)());
return _NS["lua"]["List"](lemma.splice(gel))
end)()
end);

_NS["lemma"]["loop"] = Macro(function(_LG1_0, ...)
local _LG1_1 = List(...);
return _NS["lua"]["List"](Symbol("do"), (function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_LG1_1));
gel = lemma.unsplice(gel, _NS["lemma"]["odds"](_LG1_0));
gel = lemma.unsplice(gel, Symbol("recur"));
gel = lemma.unsplice(gel, Symbol("defn"));
return _NS["lua"]["List"](lemma.splice(gel))
end)(), (function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_NS["lemma"]["evens"](_LG1_0)));
gel = lemma.unsplice(gel, Symbol("recur"));
return _NS["lua"]["List"](lemma.splice(gel))
end)())
end);

_NS["lemma"]["let-if"] = Macro(function(_LG1_0, _LG1_1, _LG1_2)
return (function(_LG2_0, _LG2_1)
return _NS["lua"]["List"](_NS["lua"]["List"](Symbol("fn"), Vector(_LG2_0), _NS["lua"]["List"](Symbol("if"), _LG2_0, _LG1_1, _LG1_2)), _LG2_1)
end)(_NS["lemma"]["first"](_LG1_0), _NS["lemma"]["second"](_LG1_0))
end);

_NS["lemma"]["let-values"] = Macro(function(_LG1_0, ...)
local _LG1_1 = List(...);
return _NS["lua"]["List"]((function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_NS["lemma"]["rest"](_LG1_1)));
gel = lemma.unsplice(gel, _LG1_0);
gel = lemma.unsplice(gel, Symbol("fn"));
return _NS["lua"]["List"](lemma.splice(gel))
end)(), _NS["lemma"]["first"](_LG1_1))
end);

_NS["lemma"]["times"] = Macro(function(_LG1_0, ...)
local _LG1_1 = List(...);
return _NS["lua"]["List"](Symbol("do"), _NS["lua"]["List"](Symbol("defn"), Symbol("once"), Vector(Symbol("i")), _NS["lua"]["List"](Symbol("if"), _NS["lua"]["List"](Symbol("="), Symbol("i"), 2), (function()
local gel = List();
gel = lemma.unsplice(gel, true);
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_LG1_1));
gel = lemma.unsplice(gel, Symbol("do"));
return _NS["lua"]["List"](lemma.splice(gel))
end)(), (function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lua"]["List"](Symbol("once"), _NS["lua"]["List"](Symbol("-"), Symbol("i"), 1)));
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_LG1_1));
gel = lemma.unsplice(gel, Symbol("do"));
return _NS["lua"]["List"](lemma.splice(gel))
end)())), _NS["lua"]["List"](Symbol("once"), _LG1_0))
end);

(function(_LG1_0)
return _NS["lemma"]["for-each"]((function(_LG2_0)
return (function(_LG3_0)
return _NS["lua"]["eval"](_NS["lua"]["List"](Symbol("def"), _LG3_0, _NS["lua"]["List"](Symbol("fn"), Vector(Symbol("a")), _NS["lua"]["List"](Symbol("="), _NS["lua"]["List"](Symbol("lua/type"), Symbol("a")), _LG2_0))), _NS["lua"]["env"]);

end)(_NS["lua"]["Symbol"](_NS["lemma"]["str"]("lemma/", _NS["lemma"]["method"](_LG2_0, Symbol("lower"))(), "?")))
end), _LG1_0);

end)(Vector("Vector", "HashMap", "List", "Symbol", "Macro", "Fexpr", "function", "string"))
_NS["lemma"]["mapstr"] = (function(_LG1_0, _LG1_1, _LG1_2)
_LG1_2 = (function()
if (_NS["lemma"]["="](_LG1_2)) then
return ""
elseif (true) then
return _LG1_2
end
end)()
;
return (function(_LG2_0)
return _NS["lua"]["string"]["sub"]((function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_LG2_0));
return _NS["lemma"]["str"](lemma.splice(gel))
end)(), 1, _NS["lemma"]["-"](-1, _NS["lemma"]["length"](_LG1_2)));

end)(_NS["lemma"]["map"]((function(_LG2_0)
return _NS["lemma"]["str"](_LG1_0(_LG2_0), _LG1_2);

end), _LG1_1))
end);

_NS["lemma"]["defmethod"] = Macro(function(_LG1_0, _LG1_1, ...)
local _LG1_2 = List(...);
return (function()
if (_NS["lemma"]["not"](_NS["lemma"]["vector?"](_LG1_1))) then
return _NS["lua"]["Error"](_NS["lemma"]["str"]("defmethod: expected vector, got ", _NS["lua"]["tostring"](_LG1_1), " : ", _NS["lua"]["type"](_LG1_1)))
elseif (true) then
return (function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_LG1_2));
gel = lemma.unsplice(gel, Vector(Symbol("self"), _NS["lemma"]["splice"](_LG1_1)));
gel = lemma.unsplice(gel, _LG1_0);
gel = lemma.unsplice(gel, Symbol("defn"));
return _NS["lua"]["List"](lemma.splice(gel))
end)()
end
end)()

end);

_NS["lemma"]["any?"] = (function(_LG1_0, _LG1_1)
return (function()
if (_NS["lemma"]["empty?"](_LG1_1)) then
return false
elseif (true) then
return (function(_LG2_0)
return (function()
if (_LG1_0(_LG2_0)) then
return true
elseif (true) then
return _NS["lemma"]["any?"](_LG1_0, _NS["lemma"]["rest"](_LG1_1))
end
end)()

end)(_NS["lemma"]["first"](_LG1_1))
end
end)()

end);

_NS["lemma"]["dump-meta"] = (function()
return _NS["lua"]["loadstring"]("\
    for k, v in pairs(lemma['*metadata*']) do\
      for m, w in pairs(v) do\
        io.write(tostring(k)..': '..m..' =  '..w..'\\n')\
      end\
    end\
  ")();

end);

_NS["lua"]["collectgarbage"]("collect")
-- EOF --
