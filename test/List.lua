
require '../class/List'



local t = List()
assert(t['empty?'](t))


t:cons('test')
assert(t['empty?'](t))


t = t:cons('hi')
assert(not t['empty?'](t))
assert(t:first() == 'hi')


t = t:rest()
assert(t['empty?'](t))
