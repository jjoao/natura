-   [NAME](#NAME)
-   [SYNOPSIS](#SYNOPSIS)
-   [DESCRIPTION](#DESCRIPTION)
    -   [Dici Language](#Dici-Language)
        -   [Metadata section](#Metadata-section)
        -   [Entries](#Entries)
        -   [Entries from an external / inline
            tables](#Entries-from-an-external-inline-tables)
        -   [External tables](#External-tables)
        -   [Inline tables](#Inline-tables)
    -   [Macro structure \-- Sections with a common
        domain](#Macro-structure----Sections-with-a-common-domain)
-   [AUTHOR](#AUTHOR)
-   [SEE ALSO](#SEE-ALSO)
-   [POD ERRORS](#POD-ERRORS)

# NAME {#NAME}

naterm - a dictionary DSL

# SYNOPSIS {#SYNOPSIS}

     naterm [options] file.naterm
        -lang=EN     # default PT
        -html
        -tex
        -stardict
        -debug
        -skel
        -lua      -- Output is Latex:lualatex (def: Latex:pdflatex)
        -nop2     -- ":" not a valid sep. (deft: PT: gato and PT=gato are equiv)
        -p2       -- (this is the default) --  PT: gato and PT=gato are equiv
        -lexdebug -- lex debuger while(<>){($t,$v)=lex(); print "=$t=$v\n"}

# DESCRIPTION {#DESCRIPTION}

## Dici Language {#Dici-Language}

### Metadata section {#Metadata-section}

     %name
     %title
     %author aut1 ; aut2 ; autn

     %pre < file.tex               //chapters before the dictionary
     %introdution < file.tex       // ... idem
     %pre { inline multiline preambole
       ...
     }

     %rename attrib1 attrib2
     %ignore attrib                // attribute will not be present in output
     %inline attrib

     %inv nt bt                    // inverse conceptual attribute
     %inv dom voc
     %rellang PT                   // language in relations objects

     %img  image/directory         // recomended: MEDIA/

     %lang PT EN RU                // Languages used

     %pos                          // chapters after the dictionary

### Entries {#Entries}

Entries (=concepts) are separated by emtpy lines

     !img : gato.jpg
     PT : gato
     +gen : m
     def : domestic feline
     EN : cat
     EN : pussy-cat

### Entries from an external / inline tables {#Entries-from-an-external-inline-tables}

Both External and inline tables follow a CSV-like format, where:

     Register separator is newline
     Field separator is "::"    (spaces adjacent to FS are removed)
     Sub field separator is "|" (adjacent spaces are removed)
     empty lines are ignored
     empty fields
     lines started by "#" are comments (ignored)
     ++ fiels are concatenated with the following section

### External tables {#External-tables}

     tab(list-of-plants)*
     PT : $2
     EN : $1
     dom : plants

     PT : $1
     EN : $2
     dom : zoologia
     *tab(tab1)

### Inline tables {#Inline-tables}

     PT : $1
     EN : $2
     dom : zoologia
     *tab{
     gato::cat
     cão::dog
     }

## Macro structure \-- Sections with a common domain {#Macro-structure----Sections-with-a-common-domain}

     == domain                 # dom=domain;   subdom = subsubdom = none
     == domain ==              # idem

     === subdomain             # subdom=subdomain     subsubdom = none
     === subdomain ===         # idem

     ==== subsubdomain         # subsubdom=subsubdomain
     ==== subsubdomain ====    # idem

     ==                        # domain = subdom = subsubdom = none
     ===                       # subdomain = subsubdom = none
     ====                      # subsubdomain = none

# AUTHOR {#AUTHOR}

J.Joao Almeida, jj\@di.uminho.pt

# SEE ALSO {#SEE-ALSO}

Stardict

Lingua::StarDict::Gen

tbx2naterm

LaTeX

# POD ERRORS {#POD-ERRORS}

Hey! **The above document had some coding errors, which are explained
below:**

Around line 2544:

:   Non-ASCII character seen before =encoding in \'cão::dog\'. Assuming
    UTF-8
