# the compiler: gcc for C program, define as g++ for C++
CC = gcc
CXX = g++

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -g -Wall
LIBFLAGS  = -lfl
SRC = ./src
BUILD = ./build
IFLAGS = $(addprefix -I,$(SRC) $(BUILD))

# the build target executable:
TARGET = myps

all: $(TARGET)

# parser must be built first because scanner includes it
$(TARGET): create_outdir parser scanner
	$(CXX) $(CFLAGS) $(IFLAGS) -o $(BUILD)/$(TARGET) $(BUILD)/scanner.o $(BUILD)/parser.o $(LIBFLAGS)

create_outdir:
	mkdir -p $(BUILD)

parser: parser.c
	$(CXX) $(CFLAGS) $(IFLAGS) -c -o $(BUILD)/parser.o $(BUILD)/parser.c

parser.c:
	bison -o $(BUILD)/parser.c -d -t $(SRC)/$(TARGET).y

scanner: scanner.c
	$(CXX) $(CFLAGS) $(IFLAGS) -c -o $(BUILD)/scanner.o $(BUILD)/scanner.c

scanner.c:
	flex --header-file=scanner.h -o scanner.c $(SRC)/$(TARGET).l
	mv scanner.h scanner.c $(BUILD)

clean:
	$(RM) -r build
