-- Lemma 0.2 --
_G["lemma"]["format"] = _G["lua"]["string"]["format"];

_G["lemma"]["cur-ns"] = "lemma";

_G["lemma"]["tag-splice?"] = (function(_L1_0)
return (_G["lemma"]["="]("List", _G["lemma"]["type"](_L1_0)) and _G["lemma"]["="](Symbol("splice"), _G["lemma"]["first"](_L1_0)))
end);

_G["lemma"]["seq?"] = (function(_L1_0)
return (_G["lemma"]["="]("List", _G["lemma"]["type"](_L1_0)) or _G["lemma"]["="]("Iter", _G["lemma"]["type"](_L1_0)))
end);

_G["lemma"]["congeal"] = (function(_L1_0, _L1_1)
return _G["lemma"]["str"]("(function()\
", "local gel = List();\
", _G["lemma"]["mapstr"]((function(_L2_0)
return _G["lemma"]["str"]("gel = lemma.unsplice(gel, ", _G["lemma"]["compile"](_L2_0), ");")
end), _G["lemma"]["reverse"](_L1_1), "\
"), "\
return ", _G["lemma"]["compile"](_L1_0), "(lemma.splice(gel))\
end)(")
end);

_G["lemma"]["gen-quote"] = (function(_L1_0)
return (function(_L2_0)
return _G["lemma"]["str"](_L1_0, "(", _G["lemma"]["mapstr"](_G["lemma"]["rec-quote"], _L2_0, ", "), ")")
end)
end);

_G["lemma"]["rec-quote"] = (function(_L1_0)
return (function(_L2_0)
return (function(_L3_0)
return (function()
if (_L2_0(_L3_0)) then
return _L2_0(_L3_0)(_L1_0)
elseif (true) then
return _G["lemma"]["compile"](_L1_0)
end
end)()

end)(_G["lemma"]["type"](_L1_0))
end)(Mapify{["List"] = _G["lemma"]["gen-quote"]("List"), ["Vector"] = _G["lemma"]["gen-quote"]("Vector"), ["Symbol"] = (function(_L2_0)
return _G["lemma"]["str"]("Symbol(\"", _G["lemma"]["method"]("string")(_L2_0), "\")")
end)})
end);

_G["lemma"]["handle-quote"] = (function(_L1_0)
return _G["lemma"]["rec-quote"](_G["lemma"]["first"](_L1_0))
end);

_G["lemma"]["invert-quasiquote"] = (function(_L1_0)
return (function()
if (_G["lemma"]["seq?"](_L1_0)) then
return (function()
if (_G["lemma"]["="](Symbol("unquote"), _G["lemma"]["first"](_L1_0))) then
return _G["lemma"]["second"](_L1_0)
elseif (true) then
return _G["lemma"]["cons"](Symbol("lua/List"), _G["lemma"]["map"](_G["lemma"]["invert-quasiquote"], _L1_0))
end
end)()

elseif (_G["lemma"]["="]("Vector", _G["lemma"]["type"](_L1_0))) then
return _G["lemma"]["vec"](_G["lemma"]["map"](_G["lemma"]["invert-quasiquote"], _L1_0))
elseif ("else") then
return _G["lua"]["List"](Symbol("quote"), _L1_0)
end
end)()

end);

_G["lemma"]["handle-quasiquote"] = (function(_L1_0)
return _G["lemma"]["compile"](_G["lemma"]["second"](_G["lemma"]["invert-quasiquote"](_L1_0)))
end);

_G["lemma"]["handle-fn"] = (function(_L1_0)
return (function(_L2_0, _L2_1)
_G["lemma"]["sym-push"]()return (function(_L3_0)
_G["lua"]["table"]["insert"](_L3_0, _G["lemma"]["length"](_L3_0), "return ")_G["lemma"]["sym-pop"]()return _G["lemma"]["str"](_G["lua"]["table"]["concat"](_L3_0), "\
end)")
end)(Vector("(function(", _G["lemma"]["mapstr"](_G["lemma"]["sym-new"], _L2_0, ", "), ")\
", (function(_L3_0)
return (function()
if (_L3_0) then
return _G["lemma"]["str"]("local ", _L3_0, " = List(...);\
")
elseif (true) then
return ""
end
end)()

end)(_G["lemma"]["sym-vararg?"]()), _G["lemma"]["splice"](_G["lemma"]["map"]((function(_L3_0)
return _G["lemma"]["compile"](_L3_0, true)
end), _L2_1))))
end)(_G["lemma"]["first"](_L1_0), _G["lemma"]["rest"](_L1_0))
end);

_G["lemma"]["specials"] = Mapify{["def"] = (function(_L1_0)
return (function(_L2_0, _L2_1)
return (function(_L3_0)
return (function(_L4_0)
return _G["lemma"]["str"](_L4_0, _L3_0, " = ", _G["lemma"]["compile"](_L2_1), ";\
")
end)((function()
if (_G["lemma"]["="](0, _G["lemma"]["sym-len"]())) then
return ""
elseif (true) then
return _G["lemma"]["str"]("local ", _L3_0, "; ")
end
end)()
)
end)(_G["lemma"]["sym-new"](_L2_0))
end)(_G["lemma"]["first"](_L1_0), _G["lemma"]["second"](_L1_0))
end), ["macro"] = (function(_L1_0)
return _G["lemma"]["str"]("Macro", _G["lemma"]["handle-fn"](_L1_0))
end), ["and"] = (function(_L1_0)
return _G["lemma"]["str"]("(", _G["lemma"]["mapstr"](_G["lemma"]["compile"], _L1_0, " and "), ")")
end), ["set!"] = (function(_L1_0)
return (function(_L2_0, _L2_1)
return _G["lemma"]["str"](_G["lemma"]["sym-find"](_L2_0), " = ", _G["lemma"]["compile"](_L2_1), ";\
")
end)(_G["lemma"]["first"](_L1_0), _G["lemma"]["second"](_L1_0))
end), ["or"] = (function(_L1_0)
return _G["lemma"]["str"]("(", _G["lemma"]["mapstr"](_G["lemma"]["compile"], _L1_0, " or "), ")")
end), ["ns"] = (function(_L1_0)
return (function(_L2_0)
return (function()
if (_G["lemma"]["not"](_G["lemma"]["="]("string", _G["lemma"]["type"](_L2_0)))) then
return _G["lua"]["error"](_G["lemma"]["str"]("ns: string expected (Got ", _G["lemma"]["type"](_L2_0), ")"))
elseif (true) then
return (function()
_G["lemma"]["add-ns"](_L2_0)_G["lemma"]["cur-ns"] = _L2_0;
return _G["lemma"]["str"]("lemma['cur-ns'] = '", _L2_0, "';\
")
end)()
end
end)()

end)(_G["lemma"]["first"](_L1_0))
end), ["quote"] = _G["lemma"]["handle-quote"], ["fn"] = _G["lemma"]["handle-fn"], ["quasiquote"] = _G["lemma"]["handle-quasiquote"], ["cond"] = (function(_L1_0)
return (function(_L2_0, _L2_1)
return _G["lemma"]["str"]("(function()\
", "if (", _G["lemma"]["compile"](_G["lemma"]["first"](_L2_0)), ") then\
return ", _G["lemma"]["compile"](_G["lemma"]["first"](_L2_1)), (function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_G["lemma"]["map"]((function(_L3_0, _L3_1)
return _G["lemma"]["str"]("\
elseif (", _G["lemma"]["compile"](_L3_0), ") then\
return ", _G["lemma"]["compile"](_L3_1))
end), _G["lemma"]["rest"](_L2_0), _G["lemma"]["rest"](_L2_1))));
return _G["lemma"]["str"](lemma.splice(gel))
end)(), "\
end\
end)()\
")
end)(_G["lemma"]["odds"](_L1_0), _G["lemma"]["evens"](_L1_0))
end)};

_G["lemma"]["types"] = Mapify{["number"] = (function(_L1_0)
return _G["lua"]["tostring"](_L1_0)
end), ["string"] = (function(_L1_0)
return _G["lemma"]["format"]("%q", _L1_0)
end), ["HashMap"] = (function(_L1_0)
return (function(_L2_0)
return _G["lemma"]["str"]("Mapify{", _L2_0, "}")
end)(_G["lemma"]["mapstr"]((function(_L2_0)
return _G["lemma"]["str"]("[", _G["lemma"]["compile"](_L2_0), "] = ", _G["lemma"]["compile"](_L1_0(_L2_0)))
end), _G["lemma"]["keys"](_L1_0), ", "))
end), ["Error"] = (function(_L1_0)
return _L1_0
end), ["Iter"] = (function(_L1_0)
return _G["lemma"]["compile"]((function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_L1_0));
return _G["lua"]["List"](lemma.splice(gel))
end)())
end), ["nil"] = (function(_L1_0)
return "nil"
end), ["PreHashMap"] = (function(_L1_0)
return _G["lemma"]["compile"]((function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_L1_0));
return _G["lua"]["HashMap"](lemma.splice(gel))
end)())
end), ["List"] = (function(_L1_0)
return (function(_L2_0)
return (function()
if (_G["lemma"]["specials"](_G["lemma"]["tostring"](_L2_0))) then
return _G["lemma"]["specials"](_G["lemma"]["tostring"](_L2_0))(_G["lemma"]["rest"](_L1_0))
elseif ((_G["lemma"]["="]("Symbol", _G["lemma"]["type"](_L2_0)) and _G["lemma"]["="]("Macro", _G["lemma"]["type"](_G["lua"]["eval"](_L2_0, _G["lua"]["env"]))))) then
return (function(_L3_0)
return _G["lemma"]["compile"]((function()
local gel = List();
gel = lemma.unsplice(gel, _G["lemma"]["splice"](_G["lemma"]["rest"](_L1_0)));
return _L3_0(lemma.splice(gel))
end)())
end)(_G["lemma"]["get"](_G["lua"]["eval"](_L2_0, _G["lua"]["env"]), "func"))
elseif ("else") then
return (function(_L3_0, _L3_1)
return (function()
if (_G["lemma"]["any?"](_G["lemma"]["tag-splice?"], _L3_0)) then
return _G["lemma"]["str"](_G["lemma"]["congeal"](_L2_0, _L3_0), _L3_1)
elseif (true) then
return _G["lemma"]["str"](_G["lemma"]["compile"](_L2_0), "(", _G["lemma"]["mapstr"](_G["lemma"]["compile"], _L3_0, ", "), _L3_1)
end
end)()

end)(_G["lemma"]["rest"](_L1_0), (function()
if (_G["lemma"]["stat?"]) then
return ");\
"
elseif (true) then
return ")"
end
end)()
)
end
end)()

end)(_G["lemma"]["first"](_L1_0))
end), ["Symbol"] = (function(_L1_0)
return _G["lemma"]["sym-find"](_L1_0)
end), ["Number"] = (function(_L1_0)
return _G["lemma"]["method"]("string")(_L1_0)
end), ["boolean"] = (function(_L1_0)
return (function()
if (_L1_0) then
return "true"
elseif (true) then
return "false"
end
end)()

end), ["Vector"] = (function(_L1_0)
return _G["lemma"]["str"]("Vector(", _G["lemma"]["mapstr"](_G["lemma"]["compile"], _L1_0, ", "), ")")
end)};

_G["lemma"]["compile"] = (function(_L1_0, _L1_1)
return (function()
if (_G["lemma"]["types"](_G["lemma"]["type"](_L1_0))) then
return _G["lemma"]["types"](_G["lemma"]["type"](_L1_0))(_L1_0)
elseif (true) then
return _G["lua"]["error"](_G["lemma"]["str"]("Attempt to compile unrecognized type: ", _L1_0, " : ", _G["lemma"]["type"](_L1_0), "\
"))
end
end)()

end);

_G["lemma"]["load"] = (function(_L1_0)
return (function(_L2_0)
return (function()
local _L3_0; _L3_0 = (function(_L4_0)
return (function()
if (_G["lemma"]["not"](_G["lemma"]["="](_G["lua"]["Error"]("eof"), _L4_0))) then
return (function()
(function(_L6_0)
return (function()
if (_G["lemma"]["="]("function", _G["lemma"]["type"](_L6_0))) then
return _L6_0()
elseif (true) then
return _G["lemma"]["print"](_L6_0)
end
end)()

end)(_G["lua"]["assert"](_G["lua"]["loadstring"](_L4_0)))return _L3_0(_G["lemma"]["compile"](_G["lua"]["read"](_L2_0, true)))
end)()
elseif (true) then
return nil
end
end)()

end);
return _L3_0("-- Loading")
end)()
end)(_G["lua"]["FileStream"](_G["lua"]["io"]["open"](_L1_0)))
end);

-- EOF --
