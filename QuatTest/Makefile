all: test

test:test.cpp
	g++ -ggdb -o test test.cpp

check:
	./test > my_attach.txt
	diff -Naur attach.txt my_attach.txt

clean:
	rm -f test
