EXEC = fat
SRC = fat.c

CC	=	gcc
CFLAGS	=	-g -Og -Wall -Wextra -Wpedantic -Wstrict-aliasing -Wconversion $(PKGFLAGS)

PKGFLAGS	=	`pkg-config fuse --cflags --libs`

.PHONY: all clean

all:
	$(CC) -o $(EXEC) $(SRC) $(CFLAGS)

clean:
	rm $(EXEC)
	rm fat_disk
