# Makefile for Dotfiles Stow Manager (ANSI C)

CC ?= gcc
CFLAGS ?= -Wall -Wextra -pedantic -std=c99 -O2
LDFLAGS ?=

SRC_DIR = src
TEST_DIR = tests

SRCS = $(SRC_DIR)/main.c \
       $(SRC_DIR)/logger.c \
       $(SRC_DIR)/utils.c \
       $(SRC_DIR)/registry.c \
       $(SRC_DIR)/manifest.c \
       $(SRC_DIR)/checker.c \
       $(SRC_DIR)/scanner.c \
       $(SRC_DIR)/stow.c

OBJS = $(SRCS:.c=.o)
TARGET = stow-manager

TEST_SRCS = $(TEST_DIR)/test_runner.c \
            $(SRC_DIR)/logger.c \
            $(SRC_DIR)/utils.c \
            $(SRC_DIR)/registry.c \
            $(SRC_DIR)/manifest.c \
            $(SRC_DIR)/checker.c \
            $(SRC_DIR)/scanner.c \
            $(SRC_DIR)/stow.c

TEST_OBJS = $(TEST_SRCS:.c=.o)
TEST_TARGET = test_runner

.PHONY: all clean static install test

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(TARGET) $(LDFLAGS)

static: CFLAGS += -static
static: $(TARGET)

test: $(TEST_TARGET)
	./$(TEST_TARGET)

$(TEST_TARGET): $(TEST_OBJS)
	$(CC) $(CFLAGS) $(TEST_OBJS) -o $(TEST_TARGET) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TEST_OBJS) $(TARGET) $(TEST_TARGET)

install: $(TARGET)
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 $(TARGET) $(DESTDIR)$(PREFIX)/bin/stow-manager
