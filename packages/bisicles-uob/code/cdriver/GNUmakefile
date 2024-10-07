# -*- Mode: Makefile -*- 

include ../mk/Make.defs

lib:
	cd ../lib; $(MAKE) lib



fcc := $(subst FALSE,$(FC),$(subst TRUE,mpif90,$(MPI)))

fcflag := $(subst FALSE,,$(subst TRUE,-DCH_MPI,$(MPI)))
# -lmpicxx for Intel MPI
ftestwrapper.$(config).ex : lib
	$(fcc) $(fcflag) -I../src/ -g -DCH_LANG_CC -o  ftestwrapper.$(config).ex testwrapper.F90 -L ../lib -lBisicles$(config)  $(LIBFLAGS) -lstdc++ -lmpicxx -lhdf5



ftestwrapper:  ftestwrapper.$(config).ex

all: ftestwrapper

.PHONY : ctestwrapper ftestwrapper lib
