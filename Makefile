BUILD_DIR = build
OBJS = main.o
ASM = vasm6502_oldstyle 
 
all: $(OBJS)


%.o: %.s
	@mkdir -p ${BUILD_DIR}
	${ASM} -Fbin -dotdir -o ${BUILD_DIR}/$@ $<

clean:
	rm -rf ${BUILD_DIR}

burn: all
	minipro -p AT28C256 -w ${BUILD_DIR}/main.o
