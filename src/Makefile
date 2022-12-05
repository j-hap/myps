# the compiler: gcc for C program, define as g++ for C++
CC = gcc
CXX = g++

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -g -Wall

# the build target executable:
TARGET = myps

all: $(TARGET)

$(TARGET):
	bison -d -t $(TARGET).y
	flex $(TARGET).l
	$(CXX) $(CFLAGS) -c -o scan.o lex.yy.c
	$(CXX) $(CFLAGS) -c -o parse.o $(TARGET).tab.c
	$(CXX) $(CFLAGS) -o $(TARGET) scan.o parse.o -lfl

clean:
	$(RM) $(TARGET) scan.o parse.o
