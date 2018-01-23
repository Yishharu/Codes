MOD=../mod/
LOBJ=../obj/
BIN=../bin/
MV=mv -f
F95 = f95

FFLAGS =   -I../mod -J../mod -O5


SRCS =  bessj0.f90 \
	bessj1.f90 \
	nrtype.f90 \
	nrutil.f90 \
	bessy0.f90 \
	bessy1.f90 \
	bessj.f90 \
	bessy.f90 \
	nr.f90 \
	main.f90


OBJS =  $(LOBJ)nrtype.o \
	$(LOBJ)nrutil.o \
	$(LOBJ)nr.o \
	$(LOBJ)bessj0.o \
	$(LOBJ)bessj1.o \
	$(LOBJ)bessy0.o \
	$(LOBJ)bessy1.o \
	$(LOBJ)bessj.o \
	$(LOBJ)bessy.o \
	$(LOBJ)main.o


MODS =  $(MOD)nrtype.mod \
	$(MOD)nrutil.mod \
	$(MOD)nr.mod


all:	main


main: $(BIN)main $(OBJS)
$(BIN)main: $(OBJS) $(LOBJ)main.o
	$(F95) $(FFLAGS) $(OBJS) -l lapack \
	-o $(BIN)main

$(LOBJ)main.o: main.f90
	$(F95) -c $(FFLAGS) main.f90
	$(MV) main.o $(LOBJ)

$(OBJS): $(SRCS)
	$(F95) $(FFLAGS) -c $(SRCS)
	$(MV) *.o $(LOBJ)
