#linkowanie
echo: echoo.o
	ld -o echoo echoo.o

#kompilacja
echo.o: echoo.s
	as -g -o echoo.o echoo.s

#clean
clean:
	rm -f echoo.o echoo