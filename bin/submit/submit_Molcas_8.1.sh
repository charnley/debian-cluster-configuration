#!/bin/bash
########################################
# INPUT AND OUTPUT VARIABLES
########################################
JOB=${1%.*}
OUT=$JOB.out

PWD=`pwd`

PPWD=$PWD

########################################
# JOB SPECIFIC SETTINGS
#   NNODES:        NUMBER OF NODES
#   MEM   :        MEMORY PR. CPU IN GB
#   NCPUS :        CPU NUMBER PR. NODE
#   TIME  :        ALLOCATED TIME
########################################

NNODES=1
#MEM=1
MEM=5
#MEM=6
#MEM=10
#MEM=25
#MEM=35
#MEM=50
#MEM=60
#MEM=150
#NCPUS=4
NCPUS=1
TIME=10000:00:00

########################################
# USER SETTINGS END, DO NOT TOUCH
# THE NEXT FEW VARIABLES
########################################

CMEM=`echo "$MEM"gb`
MMEM=`echo "$MEM"000`

LL_SCRIPT='mktemp.sl'

########################################
# SUBMIT SCRIPT STARTS HERE.
# ADJUST YOUR CLASS QUEUE ACCORDINGLY
#
# # @ node_usage = not_shared
#
# #SBATCH -w node149
# #SBATCH --mem=$MMEM
# #SBATCH --ntasks=$NCPUS
# #SBATCH --ntasks-per-node=$NCPUS
# #SBATCH --begin=2015-10-13T18:00:00
#
# add the following command to the list of SBATCH lines if running on coms or sauer
# #SBATCH --mem-per-cpu=$MMEM
# 
########################################

# to account for the different gcc and gfortran used during compilation
#export PATH=/kemi/luca/PROGRAMS/bin:$PATH
#export LD_LIBRARY_PATH=/kemi/luca/PROGRAMS/lib:/usr/lib64:$LD_LIBRARY_PATH

cat > $LL_SCRIPT <<!EOF
#!/bin/bash

#SBATCH --job-name=$JOB
#SBATCH --partition=teach # coms sauer teach
#SBATCH --error=$JOB.%j.err
#SBATCH --output=$JOB.%j.out
#SBATCH --nodes=$NNODES
#SBATCH --ntasks-per-node=$NCPUS
#SBATCH --no-requeue
#SBATCH --export=ALL

export Project=$JOB
#export CPUS=$(($NNODES * $NCPUS))
export MOLCAS_MEM=$(($MMEM * $NCPUS))
#export MOLCAS_MEM=$MMEM
#export MOLCAS_MEM=$SLURM_MEM_PER_CPU
export MOLCAS_DISK=204799
export P4_GLOBMEMSIZE=1048576000
export InputDir=$PPWD
export OutputDir=$PPWD
export WorkDir=/scratch/\$SLURM_JOB_ID
export OMP_NUM_THREADS=1
#export OMP_NUM_THREADS=8
#export OMP_NUM_THREADS=2
#export MKL_NUM_THREADS=8
#export MKL_NUM_THREADS=2
export MKL_NUM_THREADS=1
export I_MPI_PIN_DOMAIN=socket
export MOLCAS_NTHREADS=1
#export MOLCAS_NTHREADS=2
#export MOLCAS_NPROCS=$NCPUS
export MOLCAS_NPROCS=$(($NNODES * $NCPUS))
#export MOLCAS_NPROCS=$SLURM_NTASKS


#export MOLCAS=/software/kemi/Luca/molcas-v8.1.151001-build-gcc
#export MOLCAS=/kemi/luca/MOLCAS_DEVELOPING/developing_prod_hdf5_03
export MOLCAS=/opt/molcas

#source /kemi/luca/MOLCAS_DEVELOPING/developing_rc.sh

#module load intel
#module load intelmpi

source /home/luca/intel.sh

#export ARMCI_DEFAULT_SHMMAX=65536

export MOLCAS_OUTPUT=\$OutputDir
export MOLCAS_LINK=Yes

cd \$WorkDir

#srun /kemi/luca/bin/molcas \$InputDir/\$Project.input > \$OutputDir/\$Project.out 2> \$OutputDir/\$Project.err

\$MOLCAS/bin/molcas.exe \$InputDir/\$Project.input > \$OutputDir/\$Project.out 2> \$OutputDir/\$Project.err


cd \$OutputDir

cp \$WorkDir/*.molden .
cp \$WorkDir/*.grid .
cp \$WorkDir/*.*Orb .
cp \$WorkDir/*MOLDEN* .
cp \$WorkDir/JOBIPH $Project.JOBIPH
cp \$WorkDir/*.JobIph .
cp \$WorkDir/JOBMIX $Project.JOBMIX
cp \$WorkDir/*.JobMix .


!EOF

sbatch $LL_SCRIPT
#llsubmit $LL_SCRIPT
#rm -f $LL_SCRIPT

