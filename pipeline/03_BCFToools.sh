#!/usr/bin/bash
#SBATCH --nodes 1
#SBATCH --ntasks 16
#SBATCH --mem=96G
#SBATCH --job-name=BCFTools_call
#SBATCH --output=logs/BCFTools_call.%A.log
#SBATCH --time=5-00:00:00

#Takes each individual sample vcf from Haplotype Caller step and combines it into single, combined vcf
MEM=96g #Requires large amount of memory. Adjust according to existing resources
module load picard
module load tabix
module load gatk/3.8
module load bcftools
module load bamtools

CONFIG=config.txt

if [ -f $CONFIG ]; then
    source $CONFIG
else
        echo "Expected a config file $CONFIG"
        exit
fi
GENOMEIDX=$GENOMEFOLDER/$GENOMENAME.fasta
KNOWNSITES=
OUT=$FINALVCF/$PREFIX.all.vcf
mkdir -p $FINALVCF
CPU=1

if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi


N=$(ls bam/*.bam| sort | perl -p -e 's/\n/ /; s/(\S+)/$1/') #Lists each sample vcf by -V sample1.vcf -V sample2.vcf...

bcftools mpileup -Ou -r Supercontig_1.1:1093487-1099476 -f genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT.fasta $N | bcftools call -vmO z -o $FINALVCF/ClusATCC.MRR1.bcftools.vcf.gz
#bcftools mpileup -Ou -f genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT.fasta $N | bcftools call -vmO z -o $FINALVCF/ClusATCC.bcftools.vcf.gz


