CXX ?= c++
CXXFLAGS ?= -std=c++20 -O2 -Wall -Wextra -pedantic
TARGET := stowctl
SRC := src/main.cpp
NCURSES_CFLAGS := $(shell pkg-config --cflags ncursesw 2>/dev/null)
NCURSES_LIBS := $(shell pkg-config --libs ncursesw 2>/dev/null)

ifeq ($(strip $(NCURSES_LIBS)),)
NCURSES_LIBS := -lncursesw
endif

all: $(TARGET)

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) $(NCURSES_CFLAGS) -o $@ $< $(NCURSES_LIBS)

clean:
	rm -f $(TARGET)

.PHONY: all clean
