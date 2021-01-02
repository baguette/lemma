---
-- Things which are reversible
---

Reversible = {}

Reversible.sig = {
	'reverse'
}

for i, v in pairs(Reversible.sig) do
	lemma[v] = function(x, ...)
		if x and x[v] then
			return x[v](x, ...)
		else
			return Error(tostring(x)..' has type '..lemma.type(x)..', not Reversible')
		end
	end
end
