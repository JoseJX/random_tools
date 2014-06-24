all: test

CXXFLAGS=-I. -ggdb

test:test.cpp math/angle.o math/vector3d.o math/matrix3.o math/matrix4.o math/vector3d.o math/vector4d.o math/quat.o
	g++ ${CXXFLAGS} -o test test.cpp math/*.o


clean:
	rm -f test math/*.o
