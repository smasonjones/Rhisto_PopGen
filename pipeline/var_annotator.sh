#!/usr/bin/bash
#SBATCH --nodes 1
#SBATCH --ntasks 16
#SBATCH --mem=96G
#SBATCH --job-name=GATK.GVCFGeno
#SBATCH --output=logs/GATK.reann.log
#SBATCH --time=12:00:00

#Takes each individual sample vcf from Haplotype Caller step and combines it into single, combined vcf
MEM=96g #Requires large amount of memory. Adjust according to existing resources
module load picard
module load bcftools
module load gatk/3.8
CONFIG=config.txt

if [ -f $CONFIG ]; then
    source $CONFIG
else
	echo "Expected a config file $CONFIG"
	exit
fi
GENOMEIDX=$GENOMEFOLDER/$GENOMEFASTA
KNOWNSITES=
IN=$FI/$PREFIX.all.vcf
OUT=$FINALVCF/$PREFIX.all.reann.vcf
mkdir -p $FINALVCF
CPU=1

if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi


java -Xmx$MEM -jar $GATK \
    -T VariantAnnotator \
    -R $GENOMEIDX \
    -I bam/A12.L10B.bam \
    -A MappingQualityRankSumTest \
    -V gvcf/A12.L10B.reann.vcf \
    -o gvcf/A12.L10B.reann2.vcf \
    -nt $CPU  
