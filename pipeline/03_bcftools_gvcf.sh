#!/usr/bin/bash
#SBATCH -J bcftools_gvcf --out logs/bcftools_gvcf.%a.log
#SBATCH --ntasks 2 --nodes 1 --mem 4G --time 12:00:00

module load perl/5.20.2
module load bcftools/1.9
module load samtools/1.9

DP=5
ALNFOLDER=aln
HTCFORMAT=cram #default but may switch back to bam
HTCFOLDER=bam # default
HTCEXT=cram
if [ -f config.txt ]; then
    source config.txt
fi
VARIANTFOLDER=gvcf_samtools

mkdir -p $VARIANTFOLDER
TEMP=/scratch
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
 N=$1
fi

if [ ! $N ]; then 
 echo "need to provide a number by --array slurm or on the cmdline"
 exit
fi

MAX=$(ls $HTCFOLDER/*.$HTCEXT | wc -l | awk '{print $1}')

if [ $N -gt $MAX ]; then 
 echo "$N is too big, only $MAX lines in $SAMPLESINFO"
 exit
fi
hostname
ALNFILE=$(ls $HTCFOLDER/*.$HTCEXT | sed -n ${N}p)
echo "ALNFILE=$ALNFILE"
if [[ $ALNFILE == "" ]]; then
    echo "cannot find samples in the folder $HTCFOLDER/*.$HTCEXT, exiting ($N)"
    exit
fi
SAMPLE=$(basename $ALNFILE .$HTCEXT)

if [ ! -e $ALNFILE ]; then
    echo "Cannot find $ALNFILE"
    exit
fi
if [ ! -f $VARIANTFOLDER/$SAMPLE.g.vcf.gz ]; then
    bcftools mpileup --gvcf $DP -Ou --threads $CPU -f $REFGENOME $ALNFILE | bcftools call -mO z -o $VARIANTFOLDER/$SAMPLE.g.vcf.gz --ploidy 1 --gvcf $DP --threads $CPU
fi
