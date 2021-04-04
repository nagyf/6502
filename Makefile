objects = main.o

all: $(objects)

%.o: %.s
	vasm6502_oldstyle -Fbin -dotdir -o $@ $<

clean:
	rm -f main.o

burn: all
	minipro -p AT28C256 -w main.o
