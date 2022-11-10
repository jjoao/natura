from functools import reduce


from jjinline_files import *


print("GET JSON:")
print(type(j1))
print(j1)
print(f"j1['hello'] = {j1['hello']}" )

print(type(html))

print(html({"v3":"notas finais"}, v2="texto", v1="tit"))


r"""ILF ----------------------------------------------------------------- 

==> j1:json
{
    "hello": "world"
}

==> html:jj2

<h1>{{ v1 }}</h1>
{{ v2 }}
---
{{v3}}

"""
