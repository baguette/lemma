
require '../class/List'
require '../interface/Seq'


local s = Seq.lib.map(
	function(x) return x * 2 end,
	List():cons'5':cons'4':cons'3':cons'2':cons'1')

assert(tostring(s) == '(2 4 6 8 10)')
