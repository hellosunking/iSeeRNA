

# makefile for compile C++ programs of iSeeRNA

CXX = g++
CPPFLAG = -O2 -Wall

all: bin/calcConsv util/Wig2Array/wig2array

bin/calcConsv: src/calcConsv.cpp
	$(CXX) $(CPPFLAG) src/calcConsv.cpp -o bin/calcConsv
util/Wig2Array/wig2array: util/Wig2Array/wig2array.cpp
	$(CXX) $(CPPFLAG) util/Wig2Array/wig2array.cpp -o util/Wig2Array/wig2array

clean:
	rm -f bin/calcConsv util/Wig2Array/wig2array


