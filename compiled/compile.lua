-- Lemma 0.2 --
_NS["lemma"]["format"] = _NS["lua"]["string"]["format"];

_NS["lemma"]["cur-ns"] = "lemma";

_NS["lemma"]["tag-splice?"] = (function(_LG1_0)
return (_NS["lemma"]["="]("List", _NS["lemma"]["type"](_LG1_0)) and _NS["lemma"]["="](Symbol("splice"), _NS["lemma"]["first"](_LG1_0)))
end);

_NS["lemma"]["congeal"] = (function(_LG1_0, _LG1_1)
return _NS["lemma"]["str"]("(function()\
", "local gel = List();\
", _NS["lemma"]["mapstr"]((function(_LG2_0)
return _NS["lemma"]["str"]("gel = lemma.unsplice(gel, ", _NS["lemma"]["compile"](_LG2_0), ");");

end), _NS["lemma"]["reverse"](_LG1_1), "\
"), "\
return ", _NS["lemma"]["compile"](_LG1_0), "(lemma.splice(gel))\
end)(");

end);

_NS["lemma"]["gen-quote"] = (function(_LG1_0)
return (function(_LG2_0)
return _NS["lemma"]["str"](_LG1_0, "(", _NS["lemma"]["mapstr"](_NS["lemma"]["rec-quote"], _LG2_0, ", "), ")");

end)
end);

_NS["lemma"]["rec-quote"] = (function(_LG1_0)
return (function(_LG2_0)
return (function(_LG3_0)
return (function()
if (_LG2_0(_LG3_0)) then
return _LG2_0(_LG3_0)(_LG1_0)
elseif (true) then
return _NS["lemma"]["compile"](_LG1_0)
end
end)()

end)(_NS["lemma"]["type"](_LG1_0))
end)(Mapify{["Vector"] = _NS["lemma"]["gen-quote"]("Vector"), ["List"] = _NS["lemma"]["gen-quote"]("List"), ["Symbol"] = (function(_LG2_0)
return _NS["lemma"]["str"]("Symbol(\"", _NS["lemma"]["method"](_LG2_0, Symbol("string"))(), "\")");

end)})
end);

_NS["lemma"]["handle-quote"] = (function(_LG1_0)
return _NS["lemma"]["rec-quote"](_NS["lemma"]["first"](_LG1_0));

end);

_NS["lemma"]["invert-quasiquote"] = (function(_LG1_0)
return (function()
if (_NS["lemma"]["="]("List", _NS["lemma"]["type"](_LG1_0))) then
return (function()
if (_NS["lemma"]["="](Symbol("unquote"), _NS["lemma"]["first"](_LG1_0))) then
return _NS["lemma"]["second"](_LG1_0)
elseif (true) then
return _NS["lemma"]["cons"](Symbol("lua/List"), _NS["lemma"]["map"](_NS["lemma"]["invert-quasiquote"], _LG1_0))
end
end)()

elseif (_NS["lemma"]["="]("Vector", _NS["lemma"]["type"](_LG1_0))) then
return _NS["lemma"]["map"](_NS["lemma"]["invert-quasiquote"], _LG1_0)
elseif ("else") then
return _NS["lua"]["List"](Symbol("quote"), _LG1_0)
end
end)()

end);

_NS["lemma"]["handle-quasiquote"] = (function(_LG1_0)
return _NS["lemma"]["compile"](_NS["lemma"]["second"](_NS["lemma"]["invert-quasiquote"](_LG1_0)));

end);

_NS["lemma"]["handle-fn"] = (function(_LG1_0)
return (function(_LG2_0, _LG2_1)
_NS["lemma"]["sym-push"]();
return (function(_LG3_0)
_NS["lua"]["table"]["insert"](_LG3_0, _NS["lemma"]["length"](_LG3_0), "return ");
_NS["lemma"]["sym-pop"]();
return _NS["lemma"]["str"](_NS["lua"]["table"]["concat"](_LG3_0), "\
end)");

end)(Vector("(function(", _NS["lemma"]["mapstr"](_NS["lemma"]["sym-new"], _LG2_0, ", "), ")\
", (function(_LG3_0)
return (function()
if (_LG3_0) then
return _NS["lemma"]["str"]("local ", _LG3_0, " = List(...);\
")
elseif (true) then
return ""
end
end)()

end)(_NS["lemma"]["sym-vararg?"]()), _NS["lemma"]["splice"](_NS["lemma"]["map"]((function(_LG3_0)
return _NS["lemma"]["compile"](_LG3_0, true);

end), _LG2_1))))
end)(_NS["lemma"]["first"](_LG1_0), _NS["lemma"]["rest"](_LG1_0))
end);

_NS["lemma"]["specials"] = Mapify{["quasiquote"] = _NS["lemma"]["handle-quasiquote"], ["macro"] = (function(_LG1_0)
return _NS["lemma"]["str"]("Macro", _NS["lemma"]["handle-fn"](_LG1_0));

end), ["and"] = (function(_LG1_0)
return _NS["lemma"]["str"]("(", _NS["lemma"]["mapstr"](_NS["lemma"]["compile"], _LG1_0, " and "), ")");

end), ["or"] = (function(_LG1_0)
return _NS["lemma"]["str"]("(", _NS["lemma"]["mapstr"](_NS["lemma"]["compile"], _LG1_0, " or "), ")");

end), ["ns"] = (function(_LG1_0)
return (function(_LG2_0)
return (function()
if (_NS["lemma"]["not"](_NS["lemma"]["string?"](_LG2_0))) then
return _NS["lua"]["Error"](_NS["lemma"]["str"]("ns: string expected (Got ", _NS["lemma"]["type"](_LG2_0), ")"))
elseif (true) then
return (function()
_NS["lemma"]["cur-ns"] = _LG2_0;
return _NS["lemma"]["str"]("lemma[\"*ns*\"] = ", _LG2_0, ";\
");

end)()
end
end)()

end)(_NS["lemma"]["first"](_LG1_0))
end), ["quote"] = _NS["lemma"]["handle-quote"], ["cond"] = (function(_LG1_0)
return (function(_LG2_0, _LG2_1)
return _NS["lemma"]["str"]("(function()\
", "if (", _NS["lemma"]["compile"](_NS["lemma"]["first"](_LG2_0)), ") then\
return ", _NS["lemma"]["compile"](_NS["lemma"]["first"](_LG2_1)), (function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_NS["lemma"]["map"]((function(_LG3_0, _LG3_1)
return _NS["lemma"]["str"]("\
elseif (", _NS["lemma"]["compile"](_LG3_0), ") then\
return ", _NS["lemma"]["compile"](_LG3_1));

end), _NS["lemma"]["rest"](_LG2_0), _NS["lemma"]["rest"](_LG2_1))));
return _NS["lemma"]["str"](lemma.splice(gel))
end)(), "\
end\
end)()\
");

end)(_NS["lemma"]["odds"](_LG1_0), _NS["lemma"]["evens"](_LG1_0))
end), ["fn"] = _NS["lemma"]["handle-fn"], ["def"] = (function(_LG1_0)
return (function(_LG2_0, _LG2_1)
return (function(_LG3_0)
return (function(_LG4_0)
return _NS["lemma"]["str"](_LG4_0, _LG3_0, " = ", _NS["lemma"]["compile"](_LG2_1), ";\
");

end)((function()
if (_NS["lemma"]["="](0, _NS["lemma"]["sym-len"]())) then
return ""
elseif (true) then
return _NS["lemma"]["str"]("local ", _LG3_0, "; ")
end
end)()
)
end)(_NS["lemma"]["sym-new"](_LG2_0))
end)(_NS["lemma"]["first"](_LG1_0), _NS["lemma"]["second"](_LG1_0))
end), ["set!"] = (function(_LG1_0)
return (function(_LG2_0, _LG2_1)
return _NS["lemma"]["str"](_NS["lemma"]["sym-find"](_LG2_0), " = ", _NS["lemma"]["compile"](_LG2_1), ";\
");

end)(_NS["lemma"]["first"](_LG1_0), _NS["lemma"]["second"](_LG1_0))
end)};

_NS["lemma"]["compile"] = (function(_LG1_0, _LG1_1)
return (function(_LG2_0)
return (function()
if (_LG2_0(_NS["lemma"]["type"](_LG1_0))) then
return _LG2_0(_NS["lemma"]["type"](_LG1_0))(_LG1_0)
elseif (true) then
return _NS["lemma"]["str"]("\
-- Whoops! ", _LG1_0, " : ", _NS["lemma"]["type"](_LG1_0), "\
")
end
end)()

end)(Mapify{["PreHashMap"] = (function(_LG2_0)
return _NS["lemma"]["compile"]((function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_LG2_0));
return _NS["lua"]["HashMap"](lemma.splice(gel))
end)());

end), ["Symbol"] = (function(_LG2_0)
return _NS["lemma"]["sym-find"](_LG2_0);

end), ["HashMap"] = (function(_LG2_0)
return (function(_LG3_0)
return _NS["lemma"]["str"]("Mapify{", _LG3_0, "}");

end)(_NS["lemma"]["mapstr"]((function(_LG3_0)
return _NS["lemma"]["str"]("[", _NS["lemma"]["compile"](_LG3_0), "] = ", _NS["lemma"]["compile"](_LG2_0(_LG3_0)));

end), _NS["lemma"]["keys"](_LG2_0), ", "))
end), ["Vector"] = (function(_LG2_0)
return _NS["lemma"]["str"]("Vector(", _NS["lemma"]["mapstr"](_NS["lemma"]["compile"], _LG2_0, ", "), ")");

end), ["Number"] = (function(_LG2_0)
return _NS["lemma"]["method"](_LG2_0, Symbol("string"))();

end), ["Error"] = (function(_LG2_0)
return _LG2_0
end), ["List"] = (function(_LG2_0)
return (function(_LG3_0)
return (function()
if (_NS["lemma"]["specials"](_NS["lemma"]["tostring"](_LG3_0))) then
return _NS["lemma"]["specials"](_NS["lemma"]["tostring"](_LG3_0))(_NS["lemma"]["rest"](_LG2_0))
elseif (type(_LG3_0) == 'Symbol' and _NS["lemma"]["="]("Macro", _NS["lemma"]["type"](_NS["lua"]["eval"](_LG3_0, _NS["lua"]["env"])))) then
return (function(_LG4_0)
return _NS["lemma"]["compile"]((function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_NS["lemma"]["rest"](_LG2_0)));
return _LG4_0(lemma.splice(gel))
end)());

end)(_NS["lemma"]["get"](_NS["lua"]["eval"](_LG3_0, _NS["lua"]["env"]), "func"))
elseif ("else") then
return (function(_LG4_0, _LG4_1)
return (function()
if (_NS["lemma"]["any?"](_NS["lemma"]["tag-splice?"], _LG4_0)) then
return _NS["lemma"]["str"](_NS["lemma"]["congeal"](_LG3_0, _LG4_0), _LG4_1)
elseif (true) then
return _NS["lemma"]["str"](_NS["lemma"]["compile"](_LG3_0), "(", _NS["lemma"]["mapstr"](_NS["lemma"]["compile"], _LG4_0, ", "), _LG4_1)
end
end)()

end)(_NS["lemma"]["rest"](_LG2_0), (function()
if (_LG1_1) then
return ");\
"
elseif (true) then
return ")"
end
end)()
)
end
end)()

end)(_NS["lemma"]["first"](_LG2_0))
end), ["boolean"] = (function(_LG2_0)
return (function()
if (_LG2_0) then
return "true"
elseif (true) then
return "false"
end
end)()

end), ["number"] = (function(_LG2_0)
return _NS["lua"]["tostring"](_LG2_0);

end), ["nil"] = (function(_LG2_0)
return "nil"
end), ["string"] = (function(_LG2_0)
return _NS["lemma"]["format"]("%q", _LG2_0);

end)})
end);

_NS["lemma"]["load"] = (function(_LG1_0)
return (function(_LG2_0)
return (function()
local _LG3_0; _LG3_0 = (function(_LG4_0)
return (function()
if (_NS["lemma"]["not"](_NS["lemma"]["="](_NS["lua"]["Error"]("eof"), _LG4_0))) then
return (function()
(function(_LG6_0)
return (function()
if (_NS["lemma"]["="]("function", _NS["lemma"]["type"](_LG6_0))) then
return _LG6_0()
elseif (true) then
return _NS["lemma"]["print"](_LG6_0)
end
end)()

end)(_NS["lua"]["assert"](_NS["lua"]["loadstring"](_LG4_0)))return _LG3_0(_NS["lemma"]["compile"](_NS["lua"]["read"](_LG2_0, true)));

end)()
elseif (true) then
return nil
end
end)()

end);
return _LG3_0("-- Loading");

end)()
end)(_NS["lua"]["FileStream"](_NS["lua"]["io"]["open"](_LG1_0)))
end);

