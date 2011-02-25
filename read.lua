---
-- The Lemma Reader
---

-- TODO: 'multidispatch' reader macro

require 'type'
require 'class/List'
require 'class/Symbol'

---
-- Write an external representation of t to stdout
---
function write(t)
	if type(t) == 'string' then
		print(string.format('%q', t))
	else
		print(t)
	end
end

local symbol =			 -- this is perhaps a little too permissive
[[^([%a%-%?%*%+%%%$%^<>\\_=:&|!][%.%a%d%-%?%*%+%%%$%^<>/\\_=:&|!~@']*)]]

-- these are tried in undefined order (make them specific!)
local atoms = {
	['^([%+%-]?%d+%.?%d+)']	  = tonumber,	-- with decimal point
	['^([%+%-]?%d+)']			  = tonumber,	-- without decimal point
	[symbol]						  = Symbol
}

local number = {}
for i = 0, 9 do
	number[i] = true
end

local whitespace = {
	[' '] = true,
	['\t'] = true,
	['\n'] = true,
	[','] = true
}

local delim = {
	['('] = true,
	[')'] = true
}

-- TODO: would probably be beneficial to make this tail-recursive
function read_list(f)
	local list = List()
	
	while true do
		local c = f:get()
		if not c then return 'eof' end
		
		if c == ')' then
			return list:reverse()
		else
			f:unget(c)
			local form = read(f)
			if form == 'eof' then return 'eof' end
			list = list:cons(form)
		end
	end
end

function read_string(f)
	local str = {}
	local escape = false
	
	while true do
		local c = f:get()
		if not c then return 'eof' end
		
		if c == '"' and not escape then
			return table.concat(str)
		elseif c == '\\' then
			escape = true
			if not c then return 'eof' end
		else
			escape = false
		end
		
		if not escape then
			table.insert(str, c)
		end
	end
end

function read_keyword(f)
	local str = {}
	while true do
		local c = f:get()
		if not c then return 'eof' end
		
		if delim[c] or whitespace[c] then
			f:unget(c)
			return table.concat(str)
		end
		
		table.insert(str, c)
	end
end

function read_comment(f)
	local c
	repeat
		c = f:get()
		if not c then return 'eof' end
	until c == '\n'
	return nil
end

function read_quote(sym)
	return function(f)
		local q = List()
		return q:cons(read(f)):cons(Symbol(sym))
	end
end

function table_idx(func)
	return function(f)
		local k = read(f):string()
		local t = read(f)
		return List():cons(k):cons(t):cons(Symbol(func))
	end
end


local reader_macros = {
	['(']    = read_list,
	['"']    = read_string,
	['\\']   = table_idx('get'),
	['.']    = table_idx('method'),
	[':']    = read_keyword,
	['\'']   = read_quote('quote'),
	['`']    = read_quote('quasiquote'),
	['~']    = read_quote('unquote'),
	['@']    = read_quote('splice'),
	[';']    = read_comment,
	['#']    = 'multidispatch'
}


---
-- Read the next form from stream f
---
function read(f)
	local form = nil
	
	---
	-- If it's not whitespace, and it's not a reader macro, then
	-- it's either a symbol or number.
	---
	
	local c = f:get()
	if not c then return 'eof' end
	
	while whitespace[c] do
		c = f:get()
		if not c then return 'eof' end
	end
	
	local macro = reader_macros[c]
	
	if macro then
		form = macro(f)
	else
		local str = {}
		while not delim[c] and not whitespace[c] do
			table.insert(str, c)
			c = f:get()
			if not c then return 'eof' end
		end
		
		f:unget(c)
		str = table.concat(str)
		
		-- Do a pattern match on str to identify type of atom
		-- if no matches, lexical error
		for k, v in pairs(atoms) do
			 if string.find(str, k) then
				 form = v(str)
			 end
		end
		
		if not form then
			return nil, 'lexical error on token: '..f:get()..str
		end
	end
	
	if form then
		return form
	end
	
	return read(f)
end
