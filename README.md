# nzesm_apptainer
Definition files for creating an UM/NZESM Apptainer environment

## Introduction

Containerisation allows you to compile code that can be easily ported from one platform to another (with some restrictions). As the name suggests, all the dependencies are contained -- there are no undefined references.

The container `umenv_intel2004` described below comes with an operating system, compilers, libraries (MPI, NetCDF) and tools (fcm, cylc 7 and 8, rose). It can be thought as a replacement for the 
modules used on many high performance computers to load in dependencies (toolchain, NetCDF, etc).

## Prerequisites

First you need to have Apptainer or Singularity installed. If you're running Linux, you're in luck, just follow these [instructions](https://apptainer.org/docs/user/latest/). On Windows, you can use Windows Linux Subsystem (WSL) and on Mac you might have to install Apptainer within a Docker environment. 

## How to build a container

A container needs a definition file, e.g. `conf/umenv_intel2004.def`. This file lists the operating system, the compilers and the steps to build the libraries. It is a recipe for building the container.

To build the container, type
```
apptainer build umenv_intel2004.sif conf/umenv_intel2024.def
```
or, on a local laptop if you encounter the error `FATAL: ...permission denied`,
```
sudo apptainer build --force umenv_intel2004.sif conf/umenv_intel2024.def
```
Now take a cup of coffee.

Note: if you're using Singularity you may replace `apptainer` with `singularity` in the above and below commands.

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

apptainer build --force --fakeroot umenv_intel2004.sif conf/umenv_def.def
```

Once the build completes you will end up with a file `ummenv_intel2004.sif`, which you can copy across platforms.

## How to run a shell within a container

Assuming you have loaded the `Apptainer` module on Mahuika (or have the command `apptainer` available on your system),
```
apptainer shell umenv_intel2004.sif
```
will land you in an environment with compilers
```
Apptainer> 
```
In this environment, you should also have the commands `fcm`, `rose` and `cylc` available.

Note that you may need to bind some directories to access external data inside the container. This is achieved with the `-B` option. For instance,

```
singularity shell -B/scale_wlg_nobackup/filesets/nobackup,/nesi/nobackup,$HOME,/opt/niwa /nesi/nobackup/pletzera/umenv_intel2004.sif
```

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

## Other setup files

You will likely need to set up and edit the following files:
 1. ~/.metomi/rose.conf
 2. ~/.subversion/servers
Please refer to the Metoffice documentation on how to set these files up.

In addition, you'll need the file `$HOME/.metomi/fcm/keyword.cfg`. An example is 
```
# UM repository keywords
location{primary}[um.x] = https://code.metoffice.gov.uk/svn/um/main
revision[um.x:vn13.5] = 123226
location{primary}[um.xm] = https://code.metoffice.gov.uk/svn/um/main
location{primary}[jules.xm] = https://code.metoffice.gov.uk/svn/jules/main
location{primary}[socrates.xm] = https://code.metoffice.gov.uk/svn/socrates/main
location{primary}[casim.xm] = https://code.metoffice.gov.uk/svn/monc/casim
location{primary}[ukca.xm] = https://code.metoffice.gov.uk/svn/ukca/main
location{primary}[um_aux.xm] = https://code.metoffice.gov.uk/svn/um/aux
location{primary}[um_doc.xm] = https://code.metoffice.gov.uk/svn/um/doc
location{primary}[um_meta.xm] = https://code.metoffice.gov.uk/svn/um/meta
location{primary}[mule.xm] = https://code.metoffice.gov.uk/svn/um/mule
location{primary}[moci.xm] = https://code.metoffice.gov.uk/svn/moci/main
location{primary}[shumlib.xm] = https://code.metoffice.gov.uk/svn/utils/shumlib
location{primary}[um.offline] = file:///home/pletzera/source/um/offline
location{primary}[jules.offline] = file:///home/pletzera/source/jules/offline
location{primary}[socrates.offline] = file:///home/pletzera/source/socrates/offline
location{primary}[casim.offline] = file:///home/pletzera/source/casim/offline
location{primary}[ukca.offline] = file:///home/pletzera/source/ukca/offline
location{primary}[um_aux.offline] = file:///home/pletzera/source/um_aux/offline
location{primary}[mule.offline] = file:///home/pletzera/source/mule/offline
location{primary}[shumlib.offline] = file:///home/pletzera/source/shumlib/offline
location{primary}[lfric_apps.x-tr] = https://code.metoffice.gov.uk/svn/lfric_apps/main/trunk
location{primary}[lfric_apps.x-br] = https://code.metoffice.gov.uk/svn/lfric_apps/main/branches
location{primary}[lfric.x-tr] = https://code.metoffice.gov.uk/svn/lfric/LFRic/trunk
location{primary}[lfric.x-br] = https://code.metoffice.gov.uk/svn/lfric/LFRic/branches
# NEMO
location{primary}[nemo] = http://forge.ipsl.jussieu.fr/nemo/svn #/trunk
location{primary}[nemo.xm] = http://forge.ipsl.jussieu.fr/nemo/svn
location{primary}[nemo.x] = http://forge.ipsl.jussieu.fr/nemo/svn
```

Note the entries `.xm` in the above pointing to `https` addresses. In principles, these should point to local mirrors. Using `https` addresses will work while mirrors are being set up, however.

## Building GCOM

The Unified Model (UM) has additional dependencies, which need to be built as a second step. You will need access to the `code.metoffice.gov.uk` repository.

1. Copy the `umenv_intel2004.sif` file to the the target platform (e.g. Mahuika)
2. `module load Apptainer`
3. `apptainer shell umenv_intel2004.sif`
5. Inside the Apptainer shell type
```
git clone git@github.com:pletzer/metomi-vms.git
cd ~
bash metomi-vms/usr/local/bin/build-gcom
```
This will install install GCOM under ~/gcom/install.

## Building a coupled coupled ocean and atmospheric model

On Mahuika, you should have a file `$HOME/.cylc/projects` listing the NeSI project number to each experiment and you should have an entry 
```
u-di415 <project ID>
```
or alternatively
```
* <project ID>
```

You'll also need to define the `mysrun` command to execute code within the container, e.g. by creating a script named `mysrun` in your `$HOME/bin` directory:
```
#!/usr/bin/bash

echo "Executing srun apptainer exec /nesi/nobackup/pletzera/umenv_intel2004.sif $@"
srun apptainer exec /nesi/nobackup/pletzera/umenv_intel2004.sif $@
```
The `$HOME/bin/mysrun` should be executable (`chmod +x $HOME/bin/mysrun`) and `$HOME/bin` should be in PATH (`export PATH=$HOME/bin:$PATH`).

Make sure you have
```
/opt/nesi/share/etc/set-hpc-project
export APPTAINERENV_PREPEND_PATH=/opt/nesi/share/bin
```
in your `$HOME/.bashrc`.

In your terminal, type
```
export CYLC_VERSION=8.1.4
export UMDIR=/nesi/project/uoo03538/um
module purge
module load Apptainer/1.2.5
apptainer shell /nesi/nobackup/pletzera/umenv_intel2004.sif
```

You should now land inside the container. Type
```
cp /usr/local/XIOS/bin/xios_server.exe $HOME/bin
source /usr/local/bin/mosrs-setup-gpg-agent
```
and enter your MetOffice password. Your password has been successfully cached if the follwoing command
```
rosie hello
```
does not require entering your password and succeeds.

If for any reasons you need to re-cache your password, do
```
unset GPG_AGENT_INFO
rm ~/.gnupg/S.gpg-agent
ps -fu $USER | grep gpg
```
The `ps` command will display all the processes associated with `gpg`. Write down the process ID number that caches the password and kill it (`kill <pid>`).

To start the compilation and executiuon of the coupled model
```
rosie co u-di415
cd ~/roses/u-di415
cylc vip
```
Note: the `project ID` should match the one listed in `$HOME/.cylc/projects` for this experiment (see above).

You can monitor the progress of the compilation and execution by typing
```
cylc tui u-di415
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
apptainer exec umenv_intel2004.sif mpicc myapp.c -o myapp
```

## Running a containerised MPI application

You can either leverage the MPI inside the application
```
apptainer exec umenv_intel2004.sif mpiexec -n 4 ./myapp
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

srun apptainer exec umenv_intel2004.sif ./myapp
EOF
sbatch myapp.sl
```






