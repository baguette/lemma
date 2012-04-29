-- Lemma 0.2 --
lemma["format"] = lemma["lua"]["string"]["format"];

lemma["tag-splice?"] = (function(_L1_0)
return (lemma["="]("List", lemma["type"](_L1_0)) and lemma["="](Symbol("splice"), lemma["first"](_L1_0)))
end);

lemma["seq?"] = (function(_L1_0)
return (lemma["="]("List", lemma["type"](_L1_0)) or lemma["="]("Iter", lemma["type"](_L1_0)))
end);

lemma["congeal"] = (function(_L1_0, _L1_1)
return lemma["str"]("(function()\
", "local gel = List();\
", lemma["mapstr"]((function(_L2_0)
return lemma["str"]("gel = lemma.unsplice(gel, ", lemma["compile"](_L2_0), ");")
end), lemma["reverse"](_L1_1), "\
"), "\
return ", lemma["compile"](_L1_0), "(lemma.splice(gel))\
end)(")
end);

lemma["gen-quote"] = (function(_L1_0)
return (function(_L2_0)
return lemma["str"](_L1_0, "(", lemma["mapstr"](lemma["rec-quote"], _L2_0, ", "), ")")
end)
end);

lemma["rec-quote"] = (function(_L1_0)
return (function(_L2_0)
return (function(_L3_0)
return (function()
if (_L2_0(_L3_0)) then
return _L2_0(_L3_0)(_L1_0)
elseif (true) then
return lemma["compile"](_L1_0)
end
end)()

end)(lemma["type"](_L1_0))
end)(Mapify{["List"] = lemma["gen-quote"]("List"), ["Vector"] = lemma["gen-quote"]("Vector"), ["Symbol"] = (function(_L2_0)
return lemma["str"]("Symbol(\"", lemma["method"]("string")(_L2_0), "\")")
end)})
end);

lemma["handle-quote"] = (function(_L1_0)
return lemma["rec-quote"](lemma["first"](_L1_0))
end);

lemma["invert-quasiquote"] = (function(_L1_0)
return (function()
if (lemma["seq?"](_L1_0)) then
return (function()
if (lemma["="](Symbol("unquote"), lemma["first"](_L1_0))) then
return lemma["second"](_L1_0)
elseif (true) then
return lemma["cons"](Symbol("lua.List"), lemma["map"](lemma["invert-quasiquote"], _L1_0))
end
end)()

elseif (lemma["="]("Vector", lemma["type"](_L1_0))) then
return lemma["vec"](lemma["map"](lemma["invert-quasiquote"], _L1_0))
elseif ("else") then
return lemma["lua"]["List"](Symbol("quote"), _L1_0)
end
end)()

end);

lemma["handle-quasiquote"] = (function(_L1_0)
return lemma["compile"](lemma["second"](lemma["invert-quasiquote"](_L1_0)))
end);

lemma["expand-1"] = (function(_L1_0)
local _L1_1; _L1_1 = lemma["first"](_L1_0);
return (function()
if (lemma["symbol?"](_L1_1)) then
return (function()
local _L2_0; _L2_0 = lemma["get"](lemma["lua"]["lemma"], lemma["method"]("string")(_L1_1));
return (function()
if (lemma["="](lemma["type"](_L2_0), "Macro")) then
return (function()
local _L3_0; _L3_0 = lemma["get"](_L2_0, "func");
return (function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](lemma["rest"](_L1_0)));
return _L3_0(lemma.splice(gel))
end)()
end)()
elseif (true) then
return nil
end
end)()

end)()
elseif (true) then
return nil
end
end)()

end);

lemma["handle-fn"] = (function(_L1_0)
return (function(_L2_0, _L2_1)
lemma["sym-push"]()return (function(_L3_0)
lemma["lua"]["table"]["insert"](_L3_0, lemma["length"](_L3_0), "return ")lemma["sym-pop"]()return lemma["str"](lemma["lua"]["table"]["concat"](_L3_0), "\
end)")
end)(Vector("(function(", lemma["mapstr"](lemma["sym-new"], _L2_0, ", "), ")\
", (function(_L3_0)
return (function()
if (_L3_0) then
return lemma["str"]("local ", _L3_0, " = List(...);\
")
elseif (true) then
return ""
end
end)()

end)(lemma["sym-vararg?"]()), lemma["splice"](lemma["map"]((function(_L3_0)
return lemma["compile"](_L3_0, true)
end), _L2_1))))
end)(lemma["first"](_L1_0), lemma["rest"](_L1_0))
end);

lemma["specials"] = Mapify{["def"] = (function(_L1_0)
return (function(_L2_0, _L2_1)
return (function(_L3_0)
return (function(_L4_0)
return lemma["str"](_L4_0, _L3_0, " = ", lemma["compile"](_L2_1), "\
")
end)((function()
if (lemma["="](0, lemma["sym-len"]())) then
return ""
elseif (true) then
return lemma["str"]("local ", _L3_0, "; ")
end
end)()
)
end)(lemma["sym-new"](_L2_0))
end)(lemma["first"](_L1_0), lemma["second"](_L1_0))
end), ["macro"] = (function(_L1_0)
return lemma["str"]("Macro", lemma["handle-fn"](_L1_0))
end), ["and"] = (function(_L1_0)
return lemma["str"]("(", lemma["mapstr"](lemma["compile"], _L1_0, " and "), ")")
end), ["set!"] = (function(_L1_0)
return (function(_L2_0, _L2_1)
return lemma["str"](lemma["sym-find"](_L2_0), " = ", lemma["compile"](_L2_1), "\
")
end)(lemma["first"](_L1_0), lemma["second"](_L1_0))
end), ["or"] = (function(_L1_0)
return lemma["str"]("(", lemma["mapstr"](lemma["compile"], _L1_0, " or "), ")")
end), ["def-"] = (function(_L1_0)
return (function(_L2_0, _L2_1)
return (function(_L3_0)
return lemma["str"](_L3_0, " = ", lemma["compile"](_L2_1), ";\
")
end)(lemma["sym-new"](_L2_0, true))
end)(lemma["first"](_L1_0), lemma["second"](_L1_0))
end), ["quote"] = lemma["handle-quote"], ["fn"] = lemma["handle-fn"], ["quasiquote"] = lemma["handle-quasiquote"], ["cond"] = (function(_L1_0)
return (function(_L2_0, _L2_1)
return lemma["str"]("(function()\
", "if (", lemma["compile"](lemma["first"](_L2_0)), ") then\
return ", lemma["compile"](lemma["first"](_L2_1), true), (function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](lemma["map"]((function(_L3_0, _L3_1)
return lemma["str"]("\
elseif (", lemma["compile"](_L3_0), ") then\
return ", lemma["compile"](_L3_1, true))
end), lemma["rest"](_L2_0), lemma["rest"](_L2_1))));
return lemma["str"](lemma.splice(gel))
end)(), "\
end\
end)()\
")
end)(lemma["odds"](_L1_0), lemma["evens"](_L1_0))
end)};

lemma["types"] = Mapify{["number"] = (function(_L1_0)
return lemma["lua"]["tostring"](_L1_0)
end), ["string"] = (function(_L1_0)
return lemma["format"]("%q", _L1_0)
end), ["HashMap"] = (function(_L1_0)
return (function(_L2_0)
return lemma["str"]("Mapify{", _L2_0, "}")
end)(lemma["mapstr"]((function(_L2_0)
return lemma["str"]("[", lemma["compile"](_L2_0), "] = ", lemma["compile"](_L1_0(_L2_0)))
end), lemma["keys"](_L1_0), ", "))
end), ["Error"] = (function(_L1_0)
return _L1_0
end), ["Iter"] = (function(_L1_0)
return lemma["compile"]((function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](_L1_0));
return lemma["lua"]["List"](lemma.splice(gel))
end)())
end), ["nil"] = (function(_L1_0)
return "nil"
end), ["PreHashMap"] = (function(_L1_0)
return lemma["compile"]((function()
local gel = List();
gel = lemma.unsplice(gel, lemma["splice"](_L1_0));
return lemma["lua"]["HashMap"](lemma.splice(gel))
end)())
end), ["List"] = (function(_L1_0, _L1_1)
return (function(_L2_0)
return (function()
if (lemma["specials"](lemma["tostring"](_L2_0))) then
return lemma["str"](lemma["specials"](lemma["tostring"](_L2_0))(lemma["rest"](_L1_0)), (function()
if (_L1_1) then
return ";\
"
elseif (true) then
return ""
end
end)()
)
elseif ((lemma["="]("Symbol", lemma["type"](_L2_0)) and lemma["="]("Macro", lemma["type"](lemma["get"](lemma["lua"]["lemma"], lemma["method"]("string")(_L2_0)))))) then
return lemma["compile"](lemma["expand-1"](_L1_0))
elseif ("else") then
return (function(_L3_0, _L3_1)
return (function()
if (lemma["any?"](lemma["tag-splice?"], _L3_0)) then
return lemma["str"](lemma["congeal"](_L2_0, _L3_0), _L3_1)
elseif (true) then
return lemma["str"](lemma["compile"](_L2_0), "(", lemma["mapstr"](lemma["compile"], _L3_0, ", "), _L3_1)
end
end)()

end)(lemma["rest"](_L1_0), (function()
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

end)(lemma["first"](_L1_0))
end), ["Symbol"] = (function(_L1_0)
return lemma["sym-find"](_L1_0)
end), ["Number"] = (function(_L1_0)
return lemma["method"]("string")(_L1_0)
end), ["boolean"] = (function(_L1_0)
return (function()
if (_L1_0) then
return "true"
elseif (true) then
return "false"
end
end)()

end), ["Vector"] = (function(_L1_0)
return lemma["str"]("Vector(", lemma["mapstr"](lemma["compile"], _L1_0, ", "), ")")
end)};

lemma["compile"] = (function(_L1_0, _L1_1)
return (function()
if (lemma["types"](lemma["type"](_L1_0))) then
return lemma["types"](lemma["type"](_L1_0))(_L1_0, _L1_1)
elseif (true) then
return lemma["lua"]["error"](lemma["str"]("Attempt to compile unrecognized type: ", _L1_0, " : ", lemma["type"](_L1_0), "\
"))
end
end)()

end);

lemma["load"] = (function(_L1_0)
return (function(_L2_0)
return (function()
local _L3_0; _L3_0 = (function(_L4_0)
return (function()
if (lemma["not"](lemma["="](lemma["lua"]["Error"]("eof"), _L4_0))) then
return (function()
(function(_L6_0)
return (function()
if (lemma["="]("function", lemma["type"](_L6_0))) then
return _L6_0()
elseif (true) then
return lemma["print"](_L6_0)
end
end)()

end)(lemma["lua"]["assert"](lemma["lua"]["loadstring"](_L4_0)))return _L3_0(lemma["compile"](lemma["lua"]["read"](_L2_0, true)))
end)()
elseif (true) then
return nil
end
end)()

end);
return _L3_0("-- Loading")
end)()
end)(lemma["lua"]["FileStream"](lemma["lua"]["io"]["open"](_L1_0)))
end);

-- EOF --
