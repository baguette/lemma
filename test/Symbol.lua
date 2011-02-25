
require '../class/Symbol'


assert(Symbol'quote' == Symbol'quote')

assert(Symbol'quote' ~= Symbol'unquote')

assert(tostring(Symbol'quote') == 'quote')
