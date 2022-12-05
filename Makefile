# the compiler: gcc for C program, define as g++ for C++
CC = gcc
CXX = g++

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -g -Wall
INCLUDE = -Isrc -Ibuild

# the build target executable:
TARGET = myps

all: $(TARGET)

$(TARGET):
	mkdir -p build
	bison -o build/lex.yy.c -d -t src/$(TARGET).y
	flex --header-file=$(TARGET).tab.h -o build/$(TARGET).tab.c src/$(TARGET).l
	$(CXX) $(CFLAGS) $(INCLUDE) -c -o build/scan.o build/lex.yy.c
	$(CXX) $(CFLAGS) $(INCLUDE) -c -o build/parse.o build/$(TARGET).tab.c
	$(CXX) $(CFLAGS) $(INCLUDE) -o build/$(TARGET) build/scan.o build/parse.o -lfl

clean:
	$(RM) -r build
