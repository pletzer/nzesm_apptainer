
FC=gfortran
FCFLAGS=-fPIC
CXX=g++
CC=gcc

ICE_DIR=$BUILD_DIR/bisicles_gnu
BIKE_CFG=2d.Linux.64.mpicxx.gfortran.OPT.MPI
BIKE_DIR=/usr/local/build/bisicles-uob/code/
BIKE_LIBS=-L$(BIKE_DIR)/lib/ -lBisicles$(BIKE_CFG) -lChomboLibs$(BIKE_CFG) -lstdc++ -L/usr/lib/python3.12/config-3.12-x86_64-linux-gnu/ -lpython3.12 -L/usr/lib/x86_64-linux-gnu/ -lfftw3

GLIM_DIR=$(ICE_DIR)/cism/parallel
GLIM_INC=-I$(GLIM_DIR)/include
GLIM_LIBS=-L$(GLIM_DIR)/lib -lglint -lglide -lglimmer -lglimmer-solve -lglimmer-IO
CDF_INC=-I$(NETCDF_DIR)/include
CDF_LIBS=-L$(NETCDF_DIR)lib -L$(HDF5_DIR)/lib -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz
HDF_LIBS=-L$(HDF5_DIR)/lib -lhdf5_hl -lhdf5 -lz


all:	unicicles

OBJS=wrapper_mod.o gl_mod.o wrapper_main.o

#FC=mpif90
#FCFLAGS=-DNO_RESCALE -fPIE

unicicles:  $(OBJS)
	$(FC) $(FCFLAGS) -g3 -o unicicles $(OBJS) $(GLIM_LIBS) $(BIKE_LIBS) $(CDF_LIBS)

gl_mod.o:gl_mod.f90
	$(FC) $(FCFLAGS) -g3 -free $(GLIM_INC) $(CDF_INC) -c gl_mod.f90

wrapper_mod.o:wrapper_mod.f90
	$(FC) $(FCFLAGS) -g3 -free $(GLIM_INC) $(CDF_INC) -c wrapper_mod.f90

wrapper_main.o:wrapper_main.f90
	$(FC) $(FCFLAGS) -g3 -free -c wrapper_main.f90

clean:
	rm -f *.o *.mod
