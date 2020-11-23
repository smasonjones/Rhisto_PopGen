#!/usr/bin/bash
#SBATCH --mem 4G --ntasks 1 --nodes 1 -J bgzip
#SBATCH --out logs/bgzip.%a.log --time 2:00:00
#SBATCH -p short

module load samtools

N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
 N=$1
fi

if [ ! $N ]; then
 echo "need to provide a number by --array slurm or on the cmdline"
 exit
fi

DOWN=100
VCFFOLDER="vcf_down_$DOWN"
#VCFFOLDER="vcf_down"
VCFFOLDER=vcf_force
VCFFILE=$(ls $VCFFOLDER/*.vcf | sed -n ${N}p)

        bgzip -c $VCFFILE > $VCFFILE.gz
        tabix $VCFFILE.gz


