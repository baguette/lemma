---
-- The Lemma Reader
---

require 'type'
require 'env'
require 'class/List'
require 'class/Vector'
require 'class/PreHashMap'
require 'class/Symbol'
require 'class/Nil'		-- used to signal that a comment has been read
require 'class/Number'

local symbol = '(.+)'   -- this is perhaps a little too permissive

function symbol_patterns()
	return {
		full = symbol,
		table = '([^%.]*)'
	}
end

local keywords = {['true'] = true, ['false'] = false, ['nil'] = nil}

local function tovalue(x, co)
	return keywords[x]
end

local function handle_number(n, co)
	if not tonumber(n) then
		return error('lexical error on token: '..n)
	end
	if co then
		return Number(n)
	else
		return tonumber(n)
	end
end


-- these are tried in order (make them specific!)
local atoms = {
	'^([%+%-]?0x%x+)$',			handle_number,  -- hexadecimal
	'^([%+%-]?%d+%.?%d+)$',		handle_number,	-- with decimal point
	'^([%+%-]?%d+)$',			handle_number,	-- without decimal point
	'^(true)$',					tovalue,
	'^(false)$',				tovalue,
	'^(nil)$',					tovalue,
	'^'..symbol,				Symbol
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
	[')'] = true,
	['['] = true,
	[']'] = true,
	['{'] = true,
	['}'] = true
}

local function read_seq(eos, func)
	return function(f, co)
		local list = {}
		local n = 0
		
		while true do
			local c = f:get()
			if not c then return Error'eof' end
			
			while whitespace[c] do
				c = f:get()
				if not c then return Error'eof' end
			end
			
			if c == eos then
				return func(unpack(list, 1, n))
			else
				f:unget(c)
				local form = read(f, co, true)
				if form == Error'eof' then
					return Error'eof'
				elseif form ~= Nil then
					n = n + 1
					list[n] = form
				end
			end
		end
	end
end

local function read_delimed(delim, constr)
	return function(f, co)
		local str = {}
		local escape = false
		
		while true do
			local c = f:get()
			if not c then return Error'eof' end
			
			if c == delim and not escape then
				local str = table.concat(str)
				
				if constr then
					return constr(str)
				else
					return str
				end
			elseif c == 'n' and escape then
				c = '\n'
				escape = false
			elseif c == '\\' then
				if not escape then
					escape = true
				else
					c = '\\'
					escape = false
				end
			else
				escape = false
			end
			
			if not escape then
				table.insert(str, c)
			end
		end
	end
end

local function read_keyword(f, co)
	local str = {}
	while true do
		local c = f:get()
		if not c then return Error'eof' end
		
		if delim[c] or whitespace[c] then
			f:unget(c)
			return table.concat(str)
		end
		
		table.insert(str, c)
	end
end

local function read_comment(f, co)
	local c
	repeat
		c = f:get()
		if not c then return Error'eof' end
	until c == '\n'
	return Nil
end

local function read_multicomment(f, co)
	local last, c
	local level = 1
	
	while true do
		if level == 0 then
			return Nil
		end
		
		last = c
		c = f:get()
		if not c then return Error'eof' end
		
		if last == '#' and c == '|' then
			level = level + 1
		elseif last == '|' and c == '#' then
			level = level - 1
		end
	end
end

local function read_datumcomment(f, c)
	read(f, c)
	return Nil
end

local function read_quote(sym)
	return function(f, c)
		local q = List()
		return q:cons(read(f, c)):cons(Symbol(sym))
	end
end

local function table_idx(func)
	return function(f, c)
		local k = read(f, c)
		if type(k) ~= 'Symbol' then
			return error'read: dot syntax requires symbol'
		end
		return List():cons(k:string()):cons(Symbol(func))
	end
end


local reader_macros = {
	['(']    = read_seq(')', List),
	['[']    = read_seq(']', Vector),
	['{']    = read_seq('}', PreHashMap),
	['"']    = read_delimed('"'),
	['|']    = read_delimed('|', Symbol),
	['.']    = table_idx('method'),
	[':']    = read_keyword,
	["'"]    = read_quote('quote'),
	['`']    = read_quote('quasiquote'),
	['~']    = read_quote('unquote'),
	['@']    = read_quote('splice'),
	[';']    = read_comment,
	['#']    = {
		['|'] = read_multicomment,
		[';'] = read_datumcomment,
		['!'] = read_comment
	}
}


---
-- Read the next form from stream f. (Set compiling when... compiling.)
---
function read(f, compiling, waiting)
	local form = nil
	
	---
	-- If it's not whitespace, and it's not a reader macro, then
	-- it's either a symbol or number.
	---
	
	local c = f:get()
	if not c then return Error'eof' end
	
	while whitespace[c] do
		c = f:get()
		if not c then return Error'eof' end
	end
	
	local macro = reader_macros[c]
	while type(macro) == 'table' do
		c = f:get()
		if c == Error'eof' then return Error'eof' end
		macro = macro[c]
	end
	
	if type(macro) == 'function' then
		form = macro(f, compiling)
		if form == Nil then
			if waiting then
				return Nil
			end
			return read(f, compiling)
		end
	else
		local str = {}
		while not delim[c] and not whitespace[c] do
			table.insert(str, c)
			c = f:get()
			if not c then return Error'eof' end
		end
		
		f:unget(c)
		str = table.concat(str)
		
		-- Do a pattern match on str to identify type of atom
		-- if no matches, lexical error
		for i = 1, #atoms, 2 do
			if string.find(str, atoms[i]) then
				 form = atoms[i+1](str, compiling)
				 return form
			end
		end
		
		if not form then
			return error('lexical error on token: '..f:get()..str)
		end
	end
	
	return form
end
