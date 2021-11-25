# Some modules from Natura Project


## NATerm - authoring terminologies

### Install

```
sudo cpanm https://github.com/jjoao/natura/raw/master/Lingua-NATerm-0.03.tar.gz
```

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
naterm -html -lang=PT d.natterm
```

