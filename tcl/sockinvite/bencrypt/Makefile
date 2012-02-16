clean:
	@rm -f *.o bencrypt

all:	crypt

crypt:
	gcc -c blowfish.c bencrypt.c
	gcc -o bencrypt blowfish.o bencrypt.o

