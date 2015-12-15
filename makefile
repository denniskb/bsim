HOME = .
SRC_DIR = $(HOME)/src
INC_DIR = $(HOME)/include
OBJ_DIR = $(HOME)/obj
BIN_DIR = $(HOME)/bin
LIB_DIR = $(HOME)/lib

TARGET = libsnnsim.a libsnnsim_gpu.a
BIN_TARGET = $(foreach tgt, $(TARGET),  $(LIB_DIR)/$(tgt))

SPACE := $(eval) $(eval)
DIRS := $(shell find $(SRC_DIR) -maxdepth 4 -type d)
VPATH = $(subst  $(SPACE),:,$(DIRS)):.
CFILES = $(foreach dir, $(DIRS), $(wildcard ${dir}/*.c))
CUFILES = $(foreach dir, $(DIRS), $(wildcard ${dir}/*.cu))
CXXFILES = $(foreach dir, $(DIRS), $(wildcard ${dir}/*.cpp))
SRC = $(CFILES) $(CUFILES) $(CXXFILES)
CPUOBJ += $(patsubst %.c,${OBJ_DIR}/%.c.o,$(notdir ${CFILES})) $(patsubst %.cpp,${OBJ_DIR}/%.cpp.o,$(notdir ${CXXFILES}))
GPUOBJ += $(patsubst %.c,${OBJ_DIR}/%.c.o,$(notdir ${CFILES})) $(patsubst %.cu,${OBJ_DIR}/%.cu.o,$(notdir ${CUFILES})) $(patsubst %.cpp,${OBJ_DIR}/%.cpp.o,$(notdir ${CXXFILES}))

CFLAGS =  -g -O2 -Wall -std=c++11
CUFLAGS =  -g -O2 -std=c++11

.PHONY: default all clean test

default: all
all: $(BIN_TARGET)

#echo $(SRC)

$(LIB_DIR)/libsnnsim.a: $(CPUOBJ)
	ar cr $@ $^
$(LIB_DIR)/libsnnsim_gpu.a: $(GPUOBJ)
	ar cr $@ $^


$(OBJ_DIR)/%.cpp.o: %.cpp
	$(CXX) $(CFLAGS) -o $@ -c $^ -I$(INC_DIR)

$(OBJ_DIR)/%.cu.o: %.cu
	nvcc $(CUFLAGS) -o $@ -c $^ -I$(INC_DIR)

$(OBJ_DIR)/%.c.o: %.c
	$(CXX) $(CFLAGS) -o $@ -c $^ -I$(INC_DIR)



test:
	cd ./test &&  make

clean:
	rm -f  *.o $(OBJ_DIR)/* $(BIN_DIR)/* $(BIN_TARGET)
	cd ./test && make clean
