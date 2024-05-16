# nzesm_apptainer
Definition files for creating an Apptainer environment for NZESM

## Introduction

Containerisation allows you to compile code that can be easily ported from one platform to another (with some restrictions). As the name suggests, all the dependencies are contained -- there are no undefined references.

The container below comes with an operating system, compilers, and libraries, including MPI. It can be thought as a replacement of the 
module system used on many high performance computers to load in dependencies. 

## How to build a container

First you need to have Apptainer installed. If you're running Linux, you're in luck, just follow the (instructions)[https://apptainer.org/docs/user/latest/]. On Windows, you can use Windows Linux Subsystem (WSL).

A container needs a definition file, e.g. `conf/nzesmenv.def`. This file lists the operating system, the compilers and the steps to build the libraries. It is a recipe to build the container.

To build the container, type
```
apptainer build nzesmenv.sif conf/nzesmenv.def
```
which may take of the order of one hour to build. 

If you don't have access to a Linux system with Apptainer installed, you can also (build the container on Mahuika)[https://support.nesi.org.nz/hc/en-gb/articles/6008779241999-Build-an-Apptainer-container-on-a-Milan-compute-node] by submitting the follwowing SLURM job
```
#!/bin/bash -e
#SBATCH --job-name=apptainer_build
#SBATCH --partition=milan
#SBATCH --time=0-02:00:00
#SBATCH --mem=30GB
#SBATCH --cpus-per-task=2

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

apptainer build --force --fakeroot nzesmenv.sif conf/nzesmenv.def
```

Once the build completes you will end up with a file `nzesmenv.sif`, which you can copy across platforms.

## How to run a shell within a container

Assuming you have loaded the `Apptainer` module on Mahuika (or have the command `apptainer` available on your system),
```
apptainer shell nzesmenv.sif
```
This will land you in an environment with compilers
```
Apptainer> which mpiifort
/opt/intel/oneapi/compiler/2023.0.0/linux/bin/intel64/ifort
```

## How to run a command inside the container

If you want to run the `nc-config` command, for example,
```
apptainer exec nzesmenv.sif nc-config
``` 

##


## How to compile an application using the containerised environment

When running `apptainer shell` on Mahuika, directories (`$HOME`, `/nesi/project`, `/nesi/nobackup`) are mounted by default, Additional directories can be mounted with the `-B <dir>` option. 



