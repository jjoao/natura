#  Inline Files

This Python package to allow *inline files* -- files inside the program.

An inline file is a file stored within another file. This parent file can be any kind of file, but a .py file is preferred due to how an inline file is defined.

## Synopsis

```
from jjinline_files import *
print(message, message2)

"""ILF
==> message
Hello World!

==> message2
And this is all for now.
"""
```

## Definition

We use the following syntax to define an inline file:

```
r"""ILF
==> ID1
Hello World!

==> ID2:json
{
    "hello": "world"
}
"""
```

Inline files are defined inside a multiline comment or docstring.
Each "file" starts with `==> ID` or `==> ID:type`, where `ID` is the 
inline file's name. 
In the example above, there are two inline files, "ID1" and "ID2". 
ID2 has a type `json`.

If a "file" has an explicit type, the "file" will be 
processed accordingly. For example, a JSON file will be processed 
using the `json` module importer. Default type is text file. 
Currently, the module supports the following types:

- text files (default)   -- a (multiline) string
- json  -- any
- yaml  -- any
- jj2   -- jinja2 template -- defines a function(dict, **args)
- f     -- a f-string -- defines a function(dict, **args)
- csv, tsv  -- list(list(str))
- lines -- list(str)
- pughtml -- str
- pugjj2 -- jinja2 template in pug -- defines a function(dict, **args)


## File types and their importers

### yaml and json

- typical uses: configuration files, knowledge representation
- perform yaml-parse(text);
- return a python value (list, dict, etc)

```
r"""ILF
from jjinline_files import *

print(f["filename"])

==> f:json
{
    "filename": "calendar",
    "extension": "json"
}

==> g:yaml
filename: file1
extension: yaml
"""
```

### lines

- returns a list of strings --  text.splitlines()

### csv and tsv

- performs csv-parse(txt)
- return a list(list(strings))

### templates : f (fstrings) and jinja2 and pugjinja2

- return a function. Parameter:(d:dict or **args) → string

```
from jjinline_files import *
print( ppname(name="James Bont") )

"""ILF
==> ppname:f
surname {name.split()[-1]}  fullname {name}

"""
```
