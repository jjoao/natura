from functools import reduce
from jjinline_files import *


print("pughtml example:")
print(j1)

print("pugjj2 example:")

print(html({"v3":"notas finais"}, v2="texto", v1="tit", v4={1:2 , 3:4, 4:5} ))


r"""ILF ----------------------------------------------------------------- 

==>------------------------
==> j1:pughtml
html
  body
    h1 tit1
    p.
      era uma vez
      um gato maltês
    hr

==>------------------------
==> html:pugjj2
h1 {{v1}}
.mb-3.post-3333#3.4
   | {{v2}}
hr
| {{v3}}
ul
   {% for a,b in v4.items() %}
   li {{a}} == {{b}}
   {% endfor %}

"""
