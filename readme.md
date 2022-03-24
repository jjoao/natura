# Some modules from Natura Project


## NATerm - authoring terminologies

### Web use

Create a naterm terminology in your favourite editor.
Try it in https://natura.di.uminho.pt/jjbin/naterm.

### Install

Ensure you have Perl or Strawberry Perl

```
sudo cpanm https://github.com/jjoao/natura/raw/master/Lingua-NATerm-0.04.tar.gz
```

### Hello-world

Please create a file [ex1.naterm](https://raw.githubusercontent.com/jjoao/natura/master/Lingua-NATerm/ex1.naterm) with:
```
%title Dicionario de Animais
%lang PT EN
%rellang PT
%inv hpr hyp

PT: cão
EN: dog
def: é o melhor amigo do homem
hpr: mamífero

PT: gato
EN: cat
def: tem sete vidas,
   e costuma miar
hpr: mamífero

```

```
$ naterm -html -lang=PT ex1.naterm
```

and open "ex1.html"

