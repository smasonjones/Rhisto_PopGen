#!/usr/bin/bash

#SBATCH --mem=24gb --ntasks 24 --nodes 1
#SBATCH --time=48:00:00 -p batch
#SBATCH -J maketree --out logs/make_tree.%A.log


CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi

if [[ -f config.txt ]]; then
    source config.txt
else
    echo "Need a config.txt"
    exit
fi

if [[ -z $REFNAME ]]; then
    REFNAME=REF
fi
module load parallel
module unload perl
module load perl/5.20.2
module load bcftools/1.9
module load samtools/1.9
module load IQ-TREE
module load fasttree

print_fas() {
    printf ">%s\n%s\n" $1 $(bcftools query -e 'INFO/AF < 0.1' -s $1 -f '[%TGT]' $2)
}

export -f print_fas

FINALVCF=vcf_recal_sub
PREFIX_TMP=$PREFIX.all
PREFIX=$PREFIX_TMP
DOWN=

VERSION=lungonly
TREEDIR=strain_tree/
mkdir -p $TREEDIR

for TYPE in SNP INDEL
do
    root=$FINALVCF/$PREFIX.selected.$TYPE.$VERSION
    FAS=$TREEDIR/$PREFIX.$TYPE.$VERSION.mfa

    if [ -f $root.vcf ]; then
	bgzip -c $root.vcf > $root.vcf.gz
	tabix $root.vcf.gz
    fi
    vcf=$root.vcf.gz
    printf ">%s\n%s\n" $REFNAME $(bcftools query -e 'INFO/AF < 0.1' -f '%REF' ${vcf}) > $FAS
    parallel -j $CPU print_fas ::: $(bcftools query -l ${vcf}) ::: $vcf >> $FAS

    perl -ip -e 'if(/^>/){s/[\(\)#]/_/g; s/_+/_/g } else {s/[\*\.]/-/g }' $FAS

    tab=$root.bcftools.$VERSION.tab

    if [ ! -f $tab ]; then
	bcftools query -H -f '%CHROM\t%POS\t%INFO/AF\t%INFO/AC\t%INFO/AN\t%REF\t%ALT{0}[\t%TGT]\n' ${vcf} > $tab 
	bcftools query -H -e 'INFO/AF < 0.1' -f '%CHROM\t%POS\t%INFO/AF\t%INFO/AC\t%INFO/AN\t%REF\t%ALT{0}[\t%TGT]\n' ${vcf} > $root.highfreq.bcftools.tab 
    fi

    if [[ $TYPE == "SNP" && ! -f $TREEDIR/$PREFIX.$TYPE.$VERSION.fasttree.tre ]]; then
	FastTreeMP -gtr -gamma -nt < $FAS > $TREEDIR/$PREFIX.$TYPE.$VERSION.fasttree.tre
    fi   
            iqtree -nt $CPU -s $FAS -m GTR+ASC -b 100 

done
