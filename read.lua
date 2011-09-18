---
-- The Lemma Reader
---

require 'type'
require 'env'
require 'class/List'
require 'class/Vector'
require 'class/PreHashMap'
require 'class/Symbol'
require 'class/Nil'
require 'class/False'
require 'class/Number'

local symbol =			 -- this is perhaps a little too permissive
[[([%a%-%?%*%+%%%$%^<>/\\_=:&!][%.%a%d%-%?%*%+%%%$%^<>/\\_=:&|!~@']*)]]

function symbol_patterns()
	return {
		full = symbol,
		table = [[([%a%-%?%*%+%%%$%^<>/\\_=:&!][%a%d%-%?%*%+%%%$%^<>/\\_=:&|!~@']*)]],
		ns = [[([%a%-%?%*%+%%%$%^<>/\\_=:&!][%.%a%d%-%?%*%+%%%$%^<>\\_=:&|!~@']*)]]
	}
end

-- TODO: false and nil don't mean anything in lists... so basically nowhere in
--       lemma... use lemma/del as a workaround for nilifying variables
local function tovalue(x)
	local t = {['true'] = true, ['false'] = false, ['nil'] = nil}
	return t[x]
end

local handle_number = {}

-- these are tried in order (make them specific!)
local atoms = {
	'^([%+%-]?%d+%.?%d+)',		handle_number,	-- with decimal point
	'^([%+%-]?%d+)',			handle_number,	-- without decimal point
	'^(true)',					tovalue,
	'^(false)',					tovalue,
	'^(nil)',					tovalue,
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

-- TODO: would probably be beneficial to make this tail-recursive
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
				local form = read(f, co)
				if form == Error'eof' then return Error'eof' end
				n = n + 1
				list[n] = form
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
	return nil
end

local function read_multicomment(f, co)
	local last, c
	
	while true do
		last = c
		c = f:get()
		if not c then return Error'eof' end
		
		if last == '#' and c == '|' then
			read_multicomment(f)
		elseif last == '|' and c == '#' then
			return nil
		end
	end
end

local function read_datumcomment(f, c)
	read(f, c)
	return nil
end

local function read_quote(sym)
	return function(f, c)
		local q = List()
		return q:cons(read(f, c)):cons(Symbol(sym))
	end
end

local function table_idx(func)
	return function(f, c)
		local k = read(f, c):string()
		local t = read(f, c)
		return List():cons(k):cons(t):cons(Symbol(func))
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
	}
}


---
-- Read the next form from stream f. (Set compiling when... compiling.)
---
function read(f, compiling)
	local form = nil
	
	if compiling then
		local mt = { __call = function(x, n) return Number(n) end }
		setmetatable(handle_number, mt)
	else
		local mt = { __call = function(x, n) return tonumber(n) end }
		setmetatable(handle_number, mt)
	end
	
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
				 form = atoms[i+1](str)
				 return form
			end
		end
		
		if not form then
			return Error('lexical error on token: '..f:get()..str)
		end
	end
	
	return form
end
