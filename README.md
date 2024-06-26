# nzesm_apptainer
Definition files for creating an UM/NZESM Apptainer environment

## Introduction

Containerisation allows you to compile code that can be easily ported from one platform to another (with some restrictions). As the name suggests, all the dependencies are contained -- there are no undefined references.

The container `umenv_ubuntu1804` described below comes with an operating system, compilers (gfortran, gcc, g++), libraries (MPI, NetCDF) and tools (fcm, cylc 7 and 8, rose). It can be thought as a replacement for the 
modules used on many high performance computers to load in dependencies (toolchain, NetCDF, etc).

## Prerequisites

First you need to have Apptainer or Singularity installed. If you're running Linux, you're in luck, just follow these [instructions](https://apptainer.org/docs/user/latest/). On Windows, you can use Windows Linux Subsystem (WSL) and on Mac you might have to install Apptainer within a Docker environment. 

## How to build a container

A container needs a definition file, e.g. `conf/umenv_ubuntu1804.def`. This file lists the operating system, the compilers and the steps to build the libraries. It is a recipe for building the container.

To build the container, type
```
apptainer build umenv_ubuntu1804.sif conf/umenv_ubuntu1804.def
```
or, on a local laptop if you encounter the error `FATAL: ...permission denied`,
```
sudo -E apptainer build --force umenv_ubuntu1804.sif conf/umenv_ubuntu1804.def
```
Now take a cup of coffee.

Note: if you're using Singularity you may replace `apptainer` with `singularity` in the above commands.

### Building the container on NeSI

If you don't have access to a Linux system with Apptainer installed, you can also [build the container on Mahuika](https://support.nesi.org.nz/hc/en-gb/articles/6008779241999-Build-an-Apptainer-container-on-a-Milan-compute-node) by submitting the follwowing SLURM job
```
#!/bin/bash -e
#SBATCH --job-name=apptainer_build
#SBATCH --partition=milan
#SBATCH --time=0-08:00:00
#SBATCH --mem=30GB
#SBATCH --cpus-per-task=4

# load environment module
module purge
module load Apptainer

# recent Apptainer modules set APPTAINER_BIND, which typically breaks
# container builds, so unset it here
unset APPTAINER_BIND

# create a build and cache directory on nobackup storage
export APPTAINER_CACHEDIR="/nesi/nobackup/$SLURM_JOB_ACCOUNT/$USER/apptainer_cache"
export APPTAINER_TMPDIR="/nesi/nobackup/$SLURM_JOB_ACCOUNT/$USER/apptainer_tmpdir"
mkdir -p $APPTAINER_CACHEDIR $APPTAINER_TMPDIR
setfacl -b $APPTAINER_TMPDIR

apptainer build --force --fakeroot umenv_ubuntu1804.sif conf/umenv_ubuntu1804.def
```

Once the build completes you will end up with a file `ummenv_ubuntu1804.sif`, which you can copy across platforms.

## How to run a shell within a container

Assuming you have loaded the `Apptainer` module on Mahuika (or have the command `apptainer` available on your system),
```
apptainer shell umenv_ubuntu1804.sif
```
will land you in an environment with compilers
```
Apptainer> 
```
In this environment, you should also have the commands `fcm`, `rose` and `cylc` available.

## Caching your password

Assuming that you have been given access to `https://code.metoffice.gov.uk`, you can cache your password using
```
Apptainer> source /usr/local/bin/mosrs-setup-gpg-agent
```
Check that your password has been cached with the command
```
Apptainer> rosie hello
https://code.metoffice.gov.uk/rosie/u/hello: Hello alexanderpletzer
```

## Turning on some services

Some applications want to modify some directories inside the container. For instance, `cylc` may call the `at` tool to submit a task. To allow this, you need to:
  1. Invoke `apptainer shell --fakeroot --writable-tmpfs umenv_ubuntu1804.sif` with the additional `--fakeroot --writable-tmpfs` options. Option `--writable-tmpfs` allows `at` to write to `/var`. The changes are temporary, however. You don't need to worry about making permanent changes to your container. `--fakeroot` is required because some commands should be executed by root.
  2. Start the `atd` daemon inside the container, i.e. `service atd start`


## Building GCOM and shum

The Unified Model (UM) has additional dependencies, which need to be built as a second step. You will need access to the `code.metoffice.gov.uk` repository.

1. Copy the `umenv_ubuntu1804.sif` file to the the target platform (e.g. Mahuika)
2. `module load Apptainer`
3. `apptainer shell umenv_ubuntu1804.sif`
5. Inside the Apptainer shell type `um-setup`

## Building and running the atmosphere

Check out the suite, compile and run it
```
Apptainer> rosie checkout u-af836
Apptainer> cd ~/roses/u-af836
Apptainer> rose suite-run
```

## How to compile an application using the containerised environment

When running `apptainer shell` on Mahuika, directories (`$HOME`, `/nesi/project`, `/nesi/nobackup`) are mounted by default. Additional directories can be mounted with the `-B <dir>` option. 

You can use the compilers inside the container to compile your application. In the example below we compile a simple MPI C application
```
cat > myapp.c << EOF
#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    // Initialize the MPI environment
    MPI_Init(NULL, NULL);

    // Get the number of processes
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    // Get the rank of the process
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    // Get the name of the processor
    char processor_name[MPI_MAX_PROCESSOR_NAME];
    int name_len;
    MPI_Get_processor_name(processor_name, &name_len);

    // Print off a hello world message
    printf("Hello world from processor %s, rank %d out of %d processors\n",
           processor_name, world_rank, world_size);

    // Finalize the MPI environment.
    MPI_Finalize();
}
EOF
apptainer exec umenv_ubuntu1804.sif mpicc myapp.c -o myapp
```

## Running a containerised MPI application

You can either leverage the MPI inside the application
```
apptainer exec umenv_ubuntu1804.sif mpiexec -n 4 ./myapp
```
or use the hosts's MPI. In the latter case, the MPI versions inside and on the host must be compatible. On NeSI's Mahuika we recommend to use the Intel MPI. In this case your SLURM script would look like:
```
cat > myapp.sl << EOF
#!/bin/bash -e
#SBATCH --job-name=runCase14       # job name (shows up in the queue)
#SBATCH --time=01:00:00       # Walltime (HH:MM:SS)
#SBATCH --hint=nomultithread
#SBATCH --mem-per-cpu=2g             # memory (in MB)
#SBATCH --ntasks=10        # number of tasks (e.g. MPI)
#SBATCH --cpus-per-task=1     # number of cores per task (e.g. OpenMP)
#SBATCH --output=%x-%j.out    # %x and %j are replaced by job name and ID
#SBATCH --error=%x-%j.err
#SBATCH --partition=milan

ml purge
ml Apptainer

module load intel        # load the Intel MPI
export I_MPI_FABRICS=ofi # turn off shm to run on multiple nodes

srun apptainer exec -B /opt/slurm/lib64/ umenv_ubuntu1804.sif ./myapp
EOF
sbatch myapp.sl
```






