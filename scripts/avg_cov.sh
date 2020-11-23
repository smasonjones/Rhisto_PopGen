#!/usr/bin/bash
#SBATCH --mem=24gb --ntasks 4 --nodes 1
#SBATCH --time=2:00:00 -p short
#SBATCH -J avg_cov --out logs/avg_cov.%A.log



module load samtools 

N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
 N=$1
fi

if [ ! $N ]; then
 echo "need to provide a number by --array slurm or on the cmdline"
 exit
fi


ALNFILE=$(ls bam_recal_all/*.bam | sed -n ${N}p)
samtools depth $ALNFILE  |  awk '{sum+=$3} END { print "Average = ",sum/NR}' > $ALNFILE.cov
