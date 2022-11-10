from jjinline_files import f1, f2, configuration as conf, hello, f3, f4

print("Hello world!")

print(f1)
print(f2)
print(conf["id"][1])
print(hello(nome="Mundo Cruel"))

print(hello({'nome':"JJJ"}))
print(f3)
print(f4)


"""ILF -------------------------------------------------------------------

==> hello:f
Olá {nome} então

==> configuration:yaml
dir: /home/jj/doc
id: 
  - sofia
  - tiago
  - jj

==> f1
eu sou o batata

==> f2:lines
print("Batatas com bacalhau")
print("Batatas com atum")

==> f3:tsv
gat	cat
dog	cão
crocodile	crocodilo

==> f4:csv
gat,cat
dog,cão
crocodile,crocodilo

"""
