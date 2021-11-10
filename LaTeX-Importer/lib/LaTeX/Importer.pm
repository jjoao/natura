package LaTeX::Importer;

use warnings;
use strict;
our $VERSION = '0.01';
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(_syst prel prelb prelstr beamerpp );
my $imports=qr{(?:html|camila|dot|abc|pod|makefile|gnuplot|slides|pass|csv)};
use File::Which;
my $teximporter = which 'teximporter';

my $verbpar=0;

sub _syst{ my ($a,$b)=@_;
 $b ||= "die";
 # print STDERR "debug: $a\n";
 if(system($a) != 0){ 
   if($b eq "die"){ die ("system $a failed:\n\t $? $!")}
   else           { warn("system $a failed:\n\t $? $!")}
 }
}


sub prel{
    my %opt =(ti=>0, Q => "",skip=>0);
    if(ref($_[0]) eq "HASH") {%opt = (%opt , %{shift(@_)}) } ;
    my  ($a,$o)=@_;
    my $v = {};
    $o //= "-";

    open(FI,$a)    or die("Error: cant open $a\n");
    local $/; undef $/;
    my $text= <FI>;
    while($text =~ /\n[^%]*\\input\{(.*?)\}/) {my $inputfile=$1;
       open(FIN,$inputfile)    
          or open(FIN,"$inputfile.tex") 
          or die("Error: cant open $inputfile\n");
       local $/; undef $/;
       my $text1= <FIN>;
       close FIN;
       $text =~ s/\\input\{$inputfile\}/$text1/;
    }
    close FI; 

    $v->{ref}   =1        if $text =~ /\\ref\{/;
    $v->{biblatex}=1      if $text =~ /\n[^%\n]*\{biblatex\}/;
    $v->{bibtex}=1        if ($text =~ /\n[^%\n]*\\bibliography\{/ and not $v->{biblatex});
    $v->{xelatex}=1       if $text =~ /\\usepackage\{(polyglossia|fontspec)\}/;
    $v->{teximporter}=1   if $text =~ m/\\(begin\{|)import_/;
    $v->{teximporter}=1   if $text =~ m/\\(begin\{|)inline_/;
    $v->{teximporter}=1   if $text =~ m/\\(begin\{|)_$imports\b/;
    $v->{makeindex}=1     if $text =~ m/\\printindex\b/;
    $v->{toc}=1           if $text =~ m/\\tableofcontents\b/;
    $v->{beamerpp}=1      if $text =~ m/\n=\./;     ## use beamer pp 

    my $out = ">$o";
    $out = "| $teximporter $opt{Q} $out" if $opt{ti} || $v->{teximporter};

    open(FO,$out) or die("cant write to $out\n");
    print FO prelb($text);
    close FO;
    return  $v;
}

sub prelb{     ## prel and beamer pp
    my $text = shift;
    if($text =~ /\n=\./){    ## use beamer pp if necessary
       $text = beamerpp($text);
    }
    prelstr($text);
}

sub prelstr{
 my $s=shift;
 for ($s){
 my %save = ();
 my $n1 = 0;

 s{( \\verb(\W) .*? \2)
        }{ $save{++$n1}=$1;"__SSAVE${n1}__"}xges;            ## save \verb

 s{( \\begin\{[Vv]erbatim\} .*? \\end\{[Vv]erbatim\})
        }{ $save{++$n1}=$1;"__SSAVE${n1}__"}xges;            ## save verbatim

 s{([^\\]) (\%.*)
        }{ $save{++$n1}=$2;"$1__SSAVE${n1}__"}xge;           ## save comm

 s{\n===\*(.*)}{\n\\subsubsection*{$1}}g;
 s{\n===(.*)}{\n\\subsubsection{$1}}g;
 s{\n\n\d+\.\d+\.\d+\.([^\d.].*)}{\n\n\\subsubsection{$1}}g;
 s{\n==\*(.*)}{\n\\subsection*{$1}}g;
 s{\n==(.*)}{\n\\subsection{$1}}g;
 s{\n\n\d+\.\d+\.([^\d.].*)}{\n\n\\subsection{$1}}g;
 s{\n=\*(.*)}{\n\\section*{$1}}g;
 s{\n=(.*)}{\n\\section{$1}}g;
 s{\n\n\d+\.([^\d.].*)}{\n\n\\section{$1}}g;
    
 s{\\:(\n[\t ]*)\.\d}{\n\\begin{enumerate}#+#$1\\item}g;
 s{\\:(\n[\t ]*)\.\[}{\n\\begin{description}#+#$1\\item[}g;
 s{\\:(\n[\t ]*)\.}{\n\\begin{itemize}#+#$1\\item }g;
 s{:(\n[\t ]*)\.\d}{:\n\\begin{enumerate}#+#$1\\item}g;
 s{:(\n[\t ]*)\.\[}{:\n\\begin{description}#+#$1\\item[}g;
 s{:(\n[\t ]*)\.}{:\n\\begin{itemize}#+#$1\\item }g;
 while(
       s{(#\+\#)([^#]*)(\n[\t ]*)\.\d?}{$1$2$3\\item}g  or
       s{(\\begin\{  (enumerate|description|itemize)  \}  )
             \#\+\#  
             ([^#]*)
             \#([^+])
             }{$1$3\\end{$2}$4}xg){};

 s{__SSAVE(\d+)__}{$save{$1}}g;
 }
 $s;
}

sub beamerpp{
 my $aa =shift;
 for ($aa){
 $_ = sp2tex($_);

 s{\n(=\.)(=+)[ \t]*(.*)}{\n$2 $3\n$1 $3}g;

 s{ \n=\.[ \t]*(.*)
    (\n(.|\n)*?)
    (?=\n(?:=|\d\.|\\(?:part|chapter|section|subsection|begin\{frame\}|end\{document\})))}
  { my ($a,$b)=($1,$2);
    if($a){
      if($b =~ /Verbatim|\\verb\b/){ "\n\\begin{frame}[fragile]\\frametitle{$a}\n$b\n\\end{frame}\n"}
      else{ "\n\\begin{frame}\\frametitle{$a}\n$b\n\\end{frame}\n"}}
    else{
      if($b =~ /Verbatim|\\verb\b/){ "\n\\begin{frame}[fragile]\n$b\n\\end{frame}\n"}
      else{ "\n\\begin{frame}\n$b\n\\end{frame}\n"}}
  }xeg; 

 s{\n=\.}{}g;
 s{\n(:\n[ \t]*\.)}{\\$1}g;

 }
 $aa;
}

sub _math2tex{
  my $f=shift;
  $f =~ s/-->/\\rightarrow /g;           # a --> b
  $f =~ s/<--/\\leftarrow /g;            # a <-- b
  $f =~ s!/\\!\\and !g;                  # a /\ b
  $f =~ s!\\/!\\vee !g;                  # a \/ b
  $f =~ s/==>/\\doublerightarrow /g;     # a ==> b
  $f =~ s/<==/\\doubleleftarrow /g;      # a <== b
  $f;
}

sub  _txt2tex{
  my $f=shift;
  $f;
}

sub sp2tex {
   my $pagina = shift; 
   my %verb=();
   my $n=0;
   my $orange="orange";

   if ($pagina) {
     for ($pagina) {
       s/\cM//g;
       s/[ \t]+\n/\n/g;

       #Verbatim paragraphs
       s{(\\begin\{Verbatim\}[^\n]*)(.*?)(\\end\{Verbatim\})}{
          $verb{++$n}= $1._txt2tex($2).$3;
          "\n\n\caMARCA\ca$n\n"}segi;

       # delete after __END__
       s/\n__END__.*/\n/s;
       s/(\\end\{document\}).*/$1\n/s;

       #Verbatim paragraphs
       s{(\\begin\{Verbatim\}[^\n]*)(.*?)(\\end\{Verbatim\})}{
          $verb{++$n}= $1._txt2tex($2).$3;
          "\n\n\caMARCA\ca$n\n"}segi;

       #Verbatim paragraphs
       s{\n\n([ \t]+\S.*?)(?=\s*\n\S|$)}{
          $verb{++$n}= "\\begin{Verbatim}\n"._txt2tex($1)."\n\\end{Verbatim}";
          "\n\n\caMARCA\ca$n\n"}seg  if $verbpar;

       # Hard rule
       s/(\n)---+[^\n+]*($|\n)/$1\\hrule\n/g;


       # bolds, italics, tts, wiki-like
       s!_\((.+?)\)_!"\\color{$orange}\\("._math2tex($1)."\\)\\color{black}"!eg;
       s!_\[(.+?)\]_!"\n\\color{$orange}\\("._math2tex($1)."\\)\\color{black}\n"!eg;
       s!\b_\B((?:[^_\n]|\B_\B)+)\B_\b!\\emph{$1}!g;
       s!\B=\b([^=\n]+)\b=\B!"\\texttt{"._txt2tex($1)."}"!eg;
       s!\*(\[|\b)([^*]+)(\]|\b)\*!\\textbf{\\color{$orange}$2\\color{black}}!g;

       # Links...

       s/\n\x01MARCA\x01(\d+)\n/$verb{$1}/g;
     }
     return $pagina;
   } else {
     return "";
   }
}


1; # End of LaTeX::Importer

__END__

####### Options:
our ($p,
     $s,     ## no prel (skip prel)
     $twice, ## force double run of pdflatex, even without references or toc
     $f,
     $clear, ## clear temporary files after build
     $fast,  ## pdflatex once, bibtex or index if needed, but not pdflatex again
     $o,
     $Q,     ## quiet
     $debug,
     $verbpar,
     $temp,  ## tmp file name (instead of __pdflatex__$$)
     $x,     ## xelatex
     $ti);

my $ind;
my $redo;
my $preloption = "";
my $base = $temp || "__ppdflatex__$$";
my $Qtex = "";
my $texerrorsfilter = "" ; 
$clear //= 1;
$clear = 0 if $debug;
$preloption .= "-f" if $f;
$Q    = "-Q" if $Q;
$Qtex = "-interaction  nonstopmode" if $Q;
$texerrorsfilter = "| sed -n -e '/^[!]/,+2p' " if $Q;

my $a; # filename
$a = shift ;
$a = "-"  if($p and not $a);

die "usage $0 file.pre\n" unless $a;

if (!-f $a) {
    $a =~ s/\.$//;
    $a .= ".tlpp" if (-f "$a.tlpp");
    $a .= ".ptex" if (-f "$a.ptex");
    $a .= ".pre"  if (-f "$a.pre");
    $a .= ".tex"  if (-f "$a.tex");
}

my $b = $a;
$b =~ s/\.(tlpp|ptex|pre|tex)$//;

$redo = 1 if $twice;

$redo = 1 if `grep -E '\\\\ref\{' $a` unless $p;

my $teximporter =`grep -E '(\\\\|begin\{)(import_|inline_|_(html|camila|dot|abc|pod|makefile|gnuplot|slides|pass))'  $a`;

$teximporter = ($teximporter || $ti)
               ? " | teximporter $Q " 
               : " | cat ";

my $xelatex  = defined($x) 
               ? $x 
               : `grep -E '\\usepackage\{(polyglossia|fontspec)\}' $a`;

my $pdflatex = $xelatex 
               ? "xelatex" 
               : "pdflatex $Qtex ";

my $c = 0;
if ($s) {
    copy($a, "$base.tex");
} elsif($p) {
    my $pout="$teximporter";
    $pout.=" > $o" if $o;
    print STDERR "pout=$pout\na=$a\no=$o\n";
    open(FI,$a)    or die("Error: cant open '$a'\n");
    open(FO,$pout) or die("Error: cant open '$pout'\n");
    local $/; undef $/;
    my $text= <FI>;
    $c =  1 if($text =~ m/\n=\./);     ## needs beamer pp ...

    if($c){ print FO prelstr(beamerpp($text)); }
    else  { print FO prelstr(         $text ); }
    close FI;
    close FO;
    exit 0;
} else {
    $c=`grep '^=\\.' $a`;    ## needs beamer pp ...
    my $pout="$teximporter > $base.tex";
    open FI, $a    or die "Error: cant open $a\n";
    open FO, $pout or die "Error: cant open $pout\n";
    local $/; undef $/;
    my $text= <FI>;
    if($c){ print FO prelstr(beamerpp($text)); }
    else  { print FO prelstr(         $text ); }
    close FI;
    close FO;
}


_syst("$pdflatex $base $texerrorsfilter");
$c=`grep '\\\\bibliography{' $a`;
$c =~ s/\%.*//s;
$ind=`grep '\\\\printindex'  $a`;
$ind =~ s/\%.*//s;

my $toc=`grep '\\\\tableofcontents'  $a`;
$toc =~ s/\%.*//s;
##print "bibtex? = $c\n";
##print "makeindex? = $ind\n";

$redo = 1 if $toc;
# $toc && ($redo = 1);
if ($ind)  { _syst("makeindex $base")           ; $redo=1;}
if ($c)    { _syst("bibtex $base","continue")   ; $redo=1;}
if ($redo && !$fast) {
    _syst("$pdflatex $base"); _syst("$pdflatex $base");
}

if($o) { My_rename("$base.pdf" , $o );}
else   { My_rename("$base.pdf" ,  "$b.pdf");}
unlink "$base.tex" unless !$clear || $debug;

if ($clear && !$fast) { ## As caution, do not clear in fast mode
    for my $file (<$base.*>) {
        unlink $file unless $debug; ## || $file =~ /\.toc/;
    }
    for my $file (<teximporter*.log>) {
        unlink $file unless $debug;
    }
}

}

sub My_rename {
    # instead of remove old file, rename new file, copy content, remove new
    my ($from, $to) = @_;
    open F, "<$from" or die;
    open T, ">$to" or die;
    while(<F>) { print T; }
    close F;
    close T;
    unlink $from;
}

__END__

=encoding UTF-8

=head1 NAME

ppdflatex - (multiple) preprocessor for LaTeX 

=head1 SYNOPSIS

=head1 Options

 -p             = just work as a preprocessor filter
 -s             = skip prelatex
 -Q             = Quiet
 -ti            = force teximporter

 -fast
 -o=output.pdf
 -verbpar       = indented paragraphs treated as verbatim
 -debug         = does nod delete temporary files

=head1 DESCRIPTION

C<ppdflatex> compiles LaTeX into PDF and may (transparently) use some
Wiki-like preprocessors:

C<prelatex> (a very simple LaTeX preprocess with abbreviations for
sections, for lists, and tables )

C<beamerpp> (a very simple Beamer preprocess)

C<teximporter> (inline ABC, graphviz, gnuplot, CSV, and PDF,...). 

=head2 BiBteX and MakeIndex

C<bibtex> and C<makeindex> are also activated if necessary.
If C<\\bibliography> is found BibTeX is executed.
In order to make conceptual indexes,
if C<\\printindex> is found C<makeindex> is executed too.

=head1 teximporter: Inline foreign formats

In order to easilly importe external formats,
if teximporter sintax is found (example: C<\\import_graphviz{file}>) teximporter
preprocessor is executed.

  \impor_html{file.html}
  \import_slides[nup=2x3,pages={3,4,9-12}]{cookbook.pdf}
  \import_pod[h1level=3]{teximporter}

  \inline_abc{
    text in language abc
  }

  \begin{import_dot}
    digraph "Makefile" {
       f -> o;
       o -> o;
    }
  \end{import_dot}

Presently the available inline formats are:

  html
  pod       (Perl documentation format)
  slides    (PDF slides)
  camila    (formal specification language )
  gnuplot
  dot       (graphViz)
  makefileg (import makefile as a graph)
  abc       (abc music format)
  csv       (csv table)

teximporter can be used as a normal filter (see teximporter)

=head1 LateX preprocessor

=head2 sections

 = section title
 == subsection title
 === subsubsection title

=head2 lists

 ...itemize example:
  . carrots
  . onions
  . tomatos
  #

 ...enumerate example:
   .1 soup
   .1 dessert
  #

 ...description example:
   .[pizza] ...
   .[pudim] ...
  #

=head1 Beamer slides

In order to make beamer slides,
if beamerpp sintax is found (^=. title) beamerpp preprocessor is executed too.

=head2 slides notatio

 = section title
 == subsection title
 =. slide title
 =.== slide title and section at the same time

 _( math )_
 _ [math ]_
 =texttt=
 _italic_
 *bold orange*

=head2 Example of a slides presentation

 \documentclass[serif]{beamer}
 \usepackage{natslides}

 \title{  }
 \author[JJ]{J.Joao Almeida}
 \institute{Departament of ... }
 \begin{document}
 \maketitle

 =. Main Message 
 :
 . Remember that...
 #

 =. Struture of this presentation

 \tableofcontents

 =.= Introduction

 =.== Motivation

 \begin{block}{}
 \begin{Verbatim}[fontsize=\scriptsize]
 ...
 \end{Verbatim}
 \end{block}

 =.= Our tool

 \demo[The tool]{
   make a demo of ...
 }

 \emph{→ in fact ...}

 =.= Conclusions
  \fixme{to be continued}
 =.= The End


=head1 AUTHOR

J.Joao Almeida, jj@di.uminho.pt

=head1 SEE ALSO

teximporter

LaTeX, BibTeX

makeindex

perl(1).

=cut

=head1 NAME

LaTeX::Importer - Preprocessor for LaTeX capable of inlining and importing

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use LaTeX::Importer;

    my $foo = LaTeX::Importer->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 	beamerpp

=head2 	prel

=head2 	prelb

=head2 	prelstr

=head2 	sp2tex

=head1 AUTHOR

J.Joao Almeida, C<< <jj at di.uminho.pt> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 J.Joao Almeida.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
