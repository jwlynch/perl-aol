
INCLUDE = ../include

CFLAGS = -I$(INCLUDE)


all: logging.o

logging.o: logging.c $(INCLUDE)/logging.h

t: t.o logging.o

t.o: t.c $(INCLUDE)/logging.h

clean:
	rm -f *~ *.o t