CC      = gcc

#CFLAGS  = -Wall -Wextra -Werror -ansi -pedantic -std=c99 -O3 -D_XOPEN_SOURCE=700 -g
DEBUG	= -O3
CFLAGS  = -Wall -Wextra -ansi -pedantic -std=c99 $(DEBUG) -D_XOPEN_SOURCE=700
LDFLAGS = -lm -lpthread  $(DEBUG)
TARGETS = rtgen rtcrack




.PRECIOUS: %.c %.o

all: $(TARGETS)

rt%: rt%.o sm3.o md5.o sha1.o sha256.o rtable.o hashselect.h
	@mkdir -p $(@D)
	echo $(@D)
	$(CC) $(HASH)=1  $^  -o $@ $(LDFLAGS)  
%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY:clean
clean:
	rm -f *.o

destroy: clean
	rm -f $(TARGETS) *.rt

rebuild: destroy all


