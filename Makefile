# the compiler: gcc for C program, define as g++ for C++
CC = gcc

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
	$(CC) $(CFLAGS) -c -o scan.o lex.yy.c
	$(CC) $(CFLAGS) -c -o parse.o $(TARGET).tab.c
	$(CC) $(CFLAGS) -o $(TARGET) scan.o parse.o -lfl

clean:
	$(RM) $(TARGET) scan.o parse.o
