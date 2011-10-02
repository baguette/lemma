-- Lemma 0.2 --
_NS["lemma"]["format"] = _NS["lua"]["string"]["format"];

_NS["lemma"]["cur-ns"] = "lemma";

_NS["lemma"]["tag-splice?"] = (function(_L1_0)
return (_NS["lemma"]["="]("List", _NS["lemma"]["type"](_L1_0)) and _NS["lemma"]["="](Symbol("splice"), _NS["lemma"]["first"](_L1_0)))
end);

_NS["lemma"]["congeal"] = (function(_L1_0, _L1_1)
return _NS["lemma"]["str"]("(function()\
", "local gel = List();\
", _NS["lemma"]["mapstr"]((function(_L2_0)
return _NS["lemma"]["str"]("gel = lemma.unsplice(gel, ", _NS["lemma"]["compile"](_L2_0), ");");

end), _NS["lemma"]["reverse"](_L1_1), "\
"), "\
return ", _NS["lemma"]["compile"](_L1_0), "(lemma.splice(gel))\
end)(");

end);

_NS["lemma"]["gen-quote"] = (function(_L1_0)
return (function(_L2_0)
return _NS["lemma"]["str"](_L1_0, "(", _NS["lemma"]["mapstr"](_NS["lemma"]["rec-quote"], _L2_0, ", "), ")");

end)
end);

_NS["lemma"]["rec-quote"] = (function(_L1_0)
return (function(_L2_0)
return (function(_L3_0)
return (function()
if (_L2_0(_L3_0)) then
return _L2_0(_L3_0)(_L1_0)
elseif (true) then
return _NS["lemma"]["compile"](_L1_0)
end
end)()

end)(_NS["lemma"]["type"](_L1_0))
end)(Mapify{["List"] = _NS["lemma"]["gen-quote"]("List"), ["Vector"] = _NS["lemma"]["gen-quote"]("Vector"), ["Symbol"] = (function(_L2_0)
return _NS["lemma"]["str"]("Symbol(\"", _NS["lemma"]["method"](_L2_0, Symbol("string"))(), "\")");

end)})
end);

_NS["lemma"]["handle-quote"] = (function(_L1_0)
return _NS["lemma"]["rec-quote"](_NS["lemma"]["first"](_L1_0));

end);

_NS["lemma"]["invert-quasiquote"] = (function(_L1_0)
return (function()
if (_NS["lemma"]["="]("List", _NS["lemma"]["type"](_L1_0))) then
return (function()
if (_NS["lemma"]["="](Symbol("unquote"), _NS["lemma"]["first"](_L1_0))) then
return _NS["lemma"]["second"](_L1_0)
elseif (true) then
return _NS["lemma"]["cons"](Symbol("lua/List"), _NS["lemma"]["map"](_NS["lemma"]["invert-quasiquote"], _L1_0))
end
end)()

elseif (_NS["lemma"]["="]("Vector", _NS["lemma"]["type"](_L1_0))) then
return _NS["lemma"]["map"](_NS["lemma"]["invert-quasiquote"], _L1_0)
elseif ("else") then
return _NS["lua"]["List"](Symbol("quote"), _L1_0)
end
end)()

end);

_NS["lemma"]["handle-quasiquote"] = (function(_L1_0)
return _NS["lemma"]["compile"](_NS["lemma"]["second"](_NS["lemma"]["invert-quasiquote"](_L1_0)));

end);

_NS["lemma"]["handle-fn"] = (function(_L1_0)
return (function(_L2_0, _L2_1)
_NS["lemma"]["sym-push"]();
return (function(_L3_0)
_NS["lua"]["table"]["insert"](_L3_0, _NS["lemma"]["length"](_L3_0), "return ");
_NS["lemma"]["sym-pop"]();
return _NS["lemma"]["str"](_NS["lua"]["table"]["concat"](_L3_0), "\
end)");

end)(Vector("(function(", _NS["lemma"]["mapstr"](_NS["lemma"]["sym-new"], _L2_0, ", "), ")\
", (function(_L3_0)
return (function()
if (_L3_0) then
return _NS["lemma"]["str"]("local ", _L3_0, " = List(...);\
")
elseif (true) then
return ""
end
end)()

end)(_NS["lemma"]["sym-vararg?"]()), _NS["lemma"]["splice"](_NS["lemma"]["map"]((function(_L3_0)
return _NS["lemma"]["compile"](_L3_0, true);

end), _L2_1))))
end)(_NS["lemma"]["first"](_L1_0), _NS["lemma"]["rest"](_L1_0))
end);

_NS["lemma"]["specials"] = Mapify{["def"] = (function(_L1_0)
return (function(_L2_0, _L2_1)
return (function(_L3_0)
return (function(_L4_0)
return _NS["lemma"]["str"](_L4_0, _L3_0, " = ", _NS["lemma"]["compile"](_L2_1), ";\
");

end)((function()
if (_NS["lemma"]["="](0, _NS["lemma"]["sym-len"]())) then
return ""
elseif (true) then
return _NS["lemma"]["str"]("local ", _L3_0, "; ")
end
end)()
)
end)(_NS["lemma"]["sym-new"](_L2_0))
end)(_NS["lemma"]["first"](_L1_0), _NS["lemma"]["second"](_L1_0))
end), ["macro"] = (function(_L1_0)
return _NS["lemma"]["str"]("Macro", _NS["lemma"]["handle-fn"](_L1_0));

end), ["and"] = (function(_L1_0)
return _NS["lemma"]["str"]("(", _NS["lemma"]["mapstr"](_NS["lemma"]["compile"], _L1_0, " and "), ")");

end), ["set!"] = (function(_L1_0)
return (function(_L2_0, _L2_1)
return _NS["lemma"]["str"](_NS["lemma"]["sym-find"](_L2_0), " = ", _NS["lemma"]["compile"](_L2_1), ";\
");

end)(_NS["lemma"]["first"](_L1_0), _NS["lemma"]["second"](_L1_0))
end), ["or"] = (function(_L1_0)
return _NS["lemma"]["str"]("(", _NS["lemma"]["mapstr"](_NS["lemma"]["compile"], _L1_0, " or "), ")");

end), ["ns"] = (function(_L1_0)
return (function(_L2_0)
return (function()
if (_NS["lemma"]["not"](_NS["lemma"]["="]("string", _NS["lemma"]["type"](_L2_0)))) then
return _NS["lua"]["Error"](_NS["lemma"]["str"]("ns: string expected (Got ", _NS["lemma"]["type"](_L2_0), ")"))
elseif (true) then
return (function()
_NS["lemma"]["cur-ns"] = _L2_0;
return _NS["lemma"]["str"]("lemma['*ns*'] = '", _L2_0, "';\
");

end)()
end
end)()

end)(_NS["lemma"]["first"](_L1_0))
end), ["quote"] = _NS["lemma"]["handle-quote"], ["fn"] = _NS["lemma"]["handle-fn"], ["quasiquote"] = _NS["lemma"]["handle-quasiquote"], ["cond"] = (function(_L1_0)
return (function(_L2_0, _L2_1)
return _NS["lemma"]["str"]("(function()\
", "if (", _NS["lemma"]["compile"](_NS["lemma"]["first"](_L2_0)), ") then\
return ", _NS["lemma"]["compile"](_NS["lemma"]["first"](_L2_1)), (function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_NS["lemma"]["map"]((function(_L3_0, _L3_1)
return _NS["lemma"]["str"]("\
elseif (", _NS["lemma"]["compile"](_L3_0), ") then\
return ", _NS["lemma"]["compile"](_L3_1));

end), _NS["lemma"]["rest"](_L2_0), _NS["lemma"]["rest"](_L2_1))));
return _NS["lemma"]["str"](lemma.splice(gel))
end)(), "\
end\
end)()\
");

end)(_NS["lemma"]["odds"](_L1_0), _NS["lemma"]["evens"](_L1_0))
end)};

_NS["lemma"]["compile"] = (function(_L1_0, _L1_1)
return (function(_L2_0)
return (function()
if (_L2_0(_NS["lemma"]["type"](_L1_0))) then
return _L2_0(_NS["lemma"]["type"](_L1_0))(_L1_0)
elseif (true) then
return _NS["lua"]["Error"](_NS["lemma"]["str"]("Attempt to compile unrecognized type: ", _L1_0, " : ", _NS["lemma"]["type"](_L1_0), "\
"))
end
end)()

end)(Mapify{["number"] = (function(_L2_0)
return _NS["lua"]["tostring"](_L2_0);

end), ["string"] = (function(_L2_0)
return _NS["lemma"]["format"]("%q", _L2_0);

end), ["HashMap"] = (function(_L2_0)
return (function(_L3_0)
return _NS["lemma"]["str"]("Mapify{", _L3_0, "}");

end)(_NS["lemma"]["mapstr"]((function(_L3_0)
return _NS["lemma"]["str"]("[", _NS["lemma"]["compile"](_L3_0), "] = ", _NS["lemma"]["compile"](_L2_0(_L3_0)));

end), _NS["lemma"]["keys"](_L2_0), ", "))
end), ["Error"] = (function(_L2_0)
return _L2_0
end), ["nil"] = (function(_L2_0)
return "nil"
end), ["PreHashMap"] = (function(_L2_0)
return _NS["lemma"]["compile"]((function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_L2_0));
return _NS["lua"]["HashMap"](lemma.splice(gel))
end)());

end), ["List"] = (function(_L2_0)
return (function(_L3_0)
return (function()
if (_NS["lemma"]["specials"](_NS["lemma"]["tostring"](_L3_0))) then
return _NS["lemma"]["specials"](_NS["lemma"]["tostring"](_L3_0))(_NS["lemma"]["rest"](_L2_0))
elseif ((_NS["lemma"]["="]("Symbol", _NS["lemma"]["type"](_L3_0)) and _NS["lemma"]["="]("Macro", _NS["lemma"]["type"](_NS["lua"]["eval"](_L3_0, _NS["lua"]["env"]))))) then
return (function(_L4_0)
return _NS["lemma"]["compile"]((function()
local gel = List();
gel = lemma.unsplice(gel, _NS["lemma"]["splice"](_NS["lemma"]["rest"](_L2_0)));
return _L4_0(lemma.splice(gel))
end)());

end)(_NS["lemma"]["get"](_NS["lua"]["eval"](_L3_0, _NS["lua"]["env"]), "func"))
elseif ("else") then
return (function(_L4_0, _L4_1)
return (function()
if (_NS["lemma"]["any?"](_NS["lemma"]["tag-splice?"], _L4_0)) then
return _NS["lemma"]["str"](_NS["lemma"]["congeal"](_L3_0, _L4_0), _L4_1)
elseif (true) then
return _NS["lemma"]["str"](_NS["lemma"]["compile"](_L3_0), "(", _NS["lemma"]["mapstr"](_NS["lemma"]["compile"], _L4_0, ", "), _L4_1)
end
end)()

end)(_NS["lemma"]["rest"](_L2_0), (function()
if (_L1_1) then
return ");\
"
elseif (true) then
return ")"
end
end)()
)
end
end)()

end)(_NS["lemma"]["first"](_L2_0))
end), ["Symbol"] = (function(_L2_0)
return _NS["lemma"]["sym-find"](_L2_0);

end), ["Number"] = (function(_L2_0)
return _NS["lemma"]["method"](_L2_0, Symbol("string"))();

end), ["boolean"] = (function(_L2_0)
return (function()
if (_L2_0) then
return "true"
elseif (true) then
return "false"
end
end)()

end), ["Vector"] = (function(_L2_0)
return _NS["lemma"]["str"]("Vector(", _NS["lemma"]["mapstr"](_NS["lemma"]["compile"], _L2_0, ", "), ")");

end)})
end);

_NS["lemma"]["load"] = (function(_L1_0)
return (function(_L2_0)
return (function()
local _L3_0; _L3_0 = (function(_L4_0)
return (function()
if (_NS["lemma"]["not"](_NS["lemma"]["="](_NS["lua"]["Error"]("eof"), _L4_0))) then
return (function()
(function(_L6_0)
return (function()
if (_NS["lemma"]["="]("function", _NS["lemma"]["type"](_L6_0))) then
return _L6_0()
elseif (true) then
return _NS["lemma"]["print"](_L6_0)
end
end)()

end)(_NS["lua"]["assert"](_NS["lua"]["loadstring"](_L4_0)))return _L3_0(_NS["lemma"]["compile"](_NS["lua"]["read"](_L2_0, true)));

end)()
elseif (true) then
return nil
end
end)()

end);
return _L3_0("-- Loading");

end)()
end)(_NS["lua"]["FileStream"](_NS["lua"]["io"]["open"](_L1_0)))
end);

-- EOF --
