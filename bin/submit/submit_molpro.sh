#!/bin/bash

if [ -n "$1" ]; then
    IN=$1
    JOB=${IN%.*}
    BASENAME=$(basename $JOB)
    SUBMIT=$JOB.sub
    PWD=`pwd`
else
    echo "Usage: submit_molpro.sh NUM_PROCS TOTAL_MEMORY_IN_GB QUEUE TIME_IN_HOURS"
    exit
fi

if [ -n "$2" ]; then
        TOTAL_PROCS=$2
else
        TOTAL_PROCS=8
fi

if [ -n "$3" ]; then
        TOTAL_MEMORY=$3
else
        TOTAL_MEMORY=46
fi

if [ -n "$4" ]; then
        Q=$4
else
        Q=coms
fi

if [ -n "$5" ]; then
        TIME=$5
else
        TIME=2000
fi


#################################################################

# The lines below format the above input to make sure,
# that both the queuing system and MOLPRO gets the right
# input.
#MOLPRO_MEMORY=$(($TOTAL_MEMORY/$TOTAL_PROCS))
MOLPRO_MEMORY=$(($TOTAL_MEMORY/$TOTAL_PROCS))
let MOLPRO_MEMORY_PER_CORE_IN_MWORDS=133*$MOLPRO_MEMORY
export MOLPRO_MEM_STRING=$MOLPRO_MEMORY_PER_CORE_IN_MWORDS"m"
export LL_MEM_STRING=$TOTAL_MEMORY"gb"
LL_MEM_STRING=$TOTAL_MEMORY"gb"

if [ $Q = "coms" ] || [ $Q = "sauer" ]   || [ $Q = "comchem" ]; then

if [ $TOTAL_PROCS == "1" ] ; then

cat > $JOB.sh <<!EOF
#!/bin/bash
#SBATCH -p $Q 
#SBATCH -c $TOTAL_PROCS
#SBATCH --ntasks=1
#SBATCH -N 1
#SBATCH --error=$HOME/logs/$BASENAME\_%j.err
#SBATCH --output=$HOME/logs/$BASENAME\_%j.out
#SBATCH --mem=$LL_MEM_STRING
#SBATCH --time=$TIME:00:00

source /opt/molpro/molpro-2012/vars.sh

export MOLPRO=/opt/molpro/molpro-2012/bin/molpro

export SCR=/scratch/\$SLURM_JOB_ID

export OPTIONS="-o $JOB.log -X -m $MOLPRO_MEM_STRING -n $TOTAL_PROCS -d \$SCR -I \$PWD -W \$PWD"

ldd \$MOLPRO\.exe

echo "Running Molpro on \`hostname\`"
echo "==="
echo "EXECUTABLE     : \$MOLPRO"
echo "OPTIONS        : \$OPTIONS"
echo "INPUT FILE     : \$JOB"
echo "JOBID          : \$SLURM_JOB_ID"
echo "TOTAL_MEMORY   : $LL_MEM_STRING"
echo "MOLPRO_MEMORY  : $MOLPRO_MEM_STRING (per core)"
echo "NPROCS         : $TOTAL_PROCS"

(time srun \$MOLPRO \$OPTIONS $JOB.inp) > $JOB\.out

!EOF

sbatch $JOB.sh

else

cat > $JOB.sh <<!EOF
#!/bin/bash
#SBATCH -p $Q 
#SBATCH -c $TOTAL_PROCS
#SBATCH --ntasks=1
#SBATCH -N 1
#SBATCH --mem=$LL_MEM_STRING
#SBATCH --time=$TIME:00:00


source /opt/molpro/molpro-2012/vars.sh

export MOLPRO=/opt/molpro/molpro-2012/bin/molpro
export SCR=/scratch/\$SLURM_JOB_ID

export OPTIONS="-o $JOB.log --no-helper-server --mppx -X -m $MOLPRO_MEM_STRING -n $TOTAL_PROCS -d \$SCR -I \$PWD -W \$PWD"

ldd \$MOLPRO\.exe

echo "Running Molpro on \`hostname\`"
echo "==="
echo "EXECUTABLE     : \$MOLPRO"
echo "OPTIONS        : \$OPTIONS"
echo "INPUT FILE     : \$JOB"
echo "JOBID          : \$SLURM_JOB_ID"
echo "TOTAL_MEMORY   : $LL_MEM_STRING"
echo "MOLPRO_MEMORY  : $MOLPRO_MEM_STRING (per core)"
echo "NPROCS         : $TOTAL_PROCS"

(time srun \$MOLPRO \$OPTIONS $JOB.inp) > $JOB\.out

!EOF

sbatch $JOB.sh

fi

else

echo "error : queue doesn't exist"

fi

