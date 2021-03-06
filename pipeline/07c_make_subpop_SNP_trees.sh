#!/usr/bin/bash

#SBATCH --mem=24gb --ntasks 4 --nodes 1
#SBATCH --time=24:00:00
#SBATCH -J makeTree --out logs/make_tree_7c.ABpop.log

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
module load bcftools
module load IQ-TREE
module load fasttree
mkdir $TREEDIR
root=$FINALVCF/$PREFIX.selected.SNP.lungonly
if [ ! -f $FINALVCF/$PREFIX.ABpop.SNP.vcf.gz ]; then
bcftools view -Ou -S vcf/ab_samples.txt $root.vcf.gz |  bcftools +fill-tags -- -t AF | bcftools view --exclude 'AF==1 || AF==0' > $FINALVCF/$PREFIX.ABpop.SNP.vcf
fi
if [ ! -f $FINALVCF/$PREFIX.Apop.SNP.vcf.gz ]; then
bcftools view -Ou -S vcf/a_samples.txt $root.vcf.gz |  bcftools +fill-tags -- -t AF | bcftools view --exclude 'AF==1 || AF==0' > $FINALVCF/$PREFIX.Apop.SNP.vcf
fi
if [ ! -f $FINALVCF/$PREFIX.Bpop.SNP.vcf ]; then
bcftools view -Ou -S vcf/b_samples.txt $root.vcf.gz |  bcftools +fill-tags -- -t AF | bcftools view --exclude 'AF==1 || AF==0' > $FINALVCF/$PREFIX.Bpop.SNP.vcf
fi

for rootbase in A B C
do
    root=$FINALVCF/$PREFIX.$rootbase.selected.SNP.lungonly
    FAS=$TREEDIR/$PREFIX.$rootbase.SNP.lungonly.fasaln
    if [ -f $root.vcf ]; then
	module load tabix
	bgzip -f $root.vcf
    fi
    vcf=$root.vcf.gz
    tab=$root.bcftools.tab
    if [ ! -f $tab ]; then
	bcftools query -H -f '%CHROM\t%POS\t%REF\t%ALT{0}[\t%TGT]\n' ${vcf} > $tab
    fi
    # I wrote a new version of this that is multithreadded if this is taking a long time 
    # we should talk about this
    # this replaces that as a fast way 
    # its two steps
    # https://github.com/stajichlab/Afum_popgenome/blob/master/variantcall/pipeline/07a_speedy_slice.sh 
    if [ ! -f $FAS ]; then
	printf '>'$REFNAME'\n' > $FAS  
	bcftools query -f '%REF' ${vcf} >> $FAS
	printf '\n' >> $FAS
	
	for samp in $(bcftools query -l ${vcf} | grep -v -P '^CL_\d+'); do
	    printf '>'${samp}'\n'
	    bcftools query -s ${samp} -f '[%TGT]' ${vcf}
	    printf '\n'
	done >> $FAS
    fi
    if [ ! -f $TREEDIR/$PREFIX.$rootbase.fasttree.tre ]; then
	FastTreeMP -gtr -gamma -nt < $FAS > $TREEDIR/$PREFIX.$rootbase.fasttree.tre
    fi
    
    iqtree -nt $CPU -s $FAS -m GTR+ASC -b 100
done
