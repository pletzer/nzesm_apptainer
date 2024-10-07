
FC=mpif90
FCFLAGS=-fPIC
CXX=mpicxx
CC=gcc

ICE_DIR=$(BUILD_DIR)/bisicles_gnu
BIKE_CFG=2d.Linux.64.mpicxx.gfortran.OPT.MPI
BIKE_DIR=/usr/local/build/bisicles-uob/code/
BIKE_LIBS=-L$(BIKE_DIR)/lib/ -lBisicles$(BIKE_CFG) -lChomboLibs$(BIKE_CFG) -lstdc++ -L/usr/lib/python3.10/config-3.10-x86_64-linux-gnu/ -lpython3.10 -L/usr/lib/x86_64-linux-gnu/

GLIM_INC=-I$(GLIM_DIR)/include
GLIM_LIBS=-L$(GLIM_DIR)/lib -lglint -lglide -lglimmer -lglimmer-solve -lglimmer-IO
CDF_INC=-I$(NETCDF_INCDIR)
CDF_LIBS=-L$(NETCDF_LIBDIR) -lnetcdff -lnetcdf -L$(HDF5_LIBDIR) -lhdf5_hl -lhdf5 -lz


all:	unicicles

OBJS=wrapper_mod.o gl_mod.o wrapper_main.o

#FC=mpif90
#FCFLAGS=-DNO_RESCALE -fPIE

# GNU compiler with Intel MPI. For OpenMPI use -lmpi_cxx
unicicles:  $(OBJS)
	$(FC) $(FCFLAGS) -g3 -o unicicles $(OBJS) $(GLIM_LIBS) $(BIKE_LIBS) $(CDF_LIBS) -lmkl_gf_lp64 -lmkl_sequential -lmkl_core -lmpicxx

gl_mod.o:gl_mod.f90
	$(FC) $(FCFLAGS) -g3 -free $(GLIM_INC) $(CDF_INC) -c gl_mod.f90

wrapper_mod.o:wrapper_mod.f90
	$(FC) $(FCFLAGS) -g3 -free $(GLIM_INC) $(CDF_INC) -c wrapper_mod.f90

wrapper_main.o:wrapper_main.f90
	$(FC) $(FCFLAGS) -g3 -free -c wrapper_main.f90

clean:
	rm -f *.o *.mod
