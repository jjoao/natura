from functools import reduce

from jjinline_files import inputs, outputs

def sort(l):
    if l == []: return l
    pivot = l[-1]
    (smaller, larger) = reduce(lambda acc, x: (acc[0], acc[1] + [x]) if x > pivot else (acc[0] + [x], acc[1]), l[:-1], ([],[]))
    return sort(smaller) + [pivot] + sort(larger)

for i,o in zip(inputs.splitlines(), outputs.splitlines()):
    print(sort(eval(i)) == eval(o))


r"""ILF
==> inputs
[6,3,5,1,2]
[7,4,2]
[1,-2,3]
[]
==> outputs
[1,2,3,5,6]
[2,4,7]
[-2,1,3]
[]
"""
