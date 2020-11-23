#!/usr/bin/bash 
#SBATCH --nodes 1 --ntasks 2 --mem 16G -p batch --time 24:00:00 --out logs/snpEff.%A.log

module unload perl
module load perl/5.20.2
module load snpEff
module load bcftools/1.9
module load tabix
module unload python
module load python/3.6.0
SNPEFFOUT=snpEff
SNPEFFGENOME=Rhizopus_stolonifer
snpEffConfig=snpEff.config
GFFGENOME=Rhisto1_all_genes_20190501.gff



#GFFGENOME=Clavispora_lusitaniae_L1B.gff3
MEM=16g

# this module defines SNPEFFJAR and SNPEFFDIR
if [ -f config.txt ]; then
	source config.txt
fi

# this module defines SNPEFFJAR and SNPEFFDIR
if [ -f config.txt ]; then
	source config.txt
fi
GFFGENOMEFILE=$GENOMEFOLDER/$GFFGENOME
FASTAGENOMEFILE=$GENOMEFOLDER/$GENOMEFASTA
if [ -z $SNPEFFJAR ]; then
 echo "need to defined \$SNPEFFJAR in module or config.txt"
 exit
fi
if [ -z $SNPEFFDIR ]; then
 echo "need to defined \$SNPEFFDIR in module or config.txt"
 exit
fi
# could make this a confi

if [ -z $FINALVCF ]; then
	echo "need a FINALVCF variable in config.txt"
	exit
fi
DOWN=
FINALVCF=vcf_recal_sub

#DOWN=recal
#FINALVCF=vcf_force

#SET=AB

SNPEFFBASE=$SNPEFFOUT

#for SET in A B C AB EvolA EvolB L1B MRR1delt minall all; do
SET=all
#echo $SNPEFFBASE
SNPEFFOUT=$SNPEFFBASE
mkdir -p $SNPEFFOUT
if [ ! -e $SNPEFFOUT/$snpEffConfig ]; then
	rsync -a $SNPEFFDIR/snpEff.config $SNPEFFOUT/$snpEffConfig
	echo "# $SNPEFFGENOME" >> $SNPEFFOUT/$snpEffConfig
  	echo "$SNPEFFGENOME.genome : Rhizopus_stolonifer" >> $SNPEFFOUT/$snpEffConfig
	chroms=$(awk '{print $1}' genome/Rhisto1_all_genes_20190501.gff | grep -v '#' | sort | uniq | perl -p -e 's/\n/, /' | perl -p -e 's/,\s+$/\n/')
	
	echo -e "\t$SNPEFFGENOME.chromosomes: $chroms" >> $SNPEFFOUT/$snpEffConfig
	#for chr in $(awk '{print $1}' genome/Rhisto1_all_genes_20190501.gff | grep -v '#' | sort | uniq)
	#do
	#    echo -e "\t$SNPEFFGENOME.$chr.codonTable : codon.Alternative_Yeast_Nuclear"
	#done

	#echo -e "\t$SNPEFFGENOME.mito_A_fumigatus_Af293.codonTable : Mold_Mitochondrial" >> $SNPEFFOUT/$snpEffConfig
	mkdir -p $SNPEFFOUT/data/$SNPEFFGENOME
	gzip -c $GFFGENOMEFILE > $SNPEFFOUT/data/$SNPEFFGENOME/genes.gff.gz
	cp $GFFGENOMEFILE $SNPEFFOUT/data/$SNPEFFGENOME/genes.gff
	rsync -aL $REFGENOME $SNPEFFOUT/data/$SNPEFFGENOME/sequences.fa

	java -Xmx$MEM -jar $SNPEFFJAR build -datadir `pwd`/$SNPEFFOUT/data -c $SNPEFFOUT/$snpEffConfig -gff2 -v $SNPEFFGENOME
fi
pushd $SNPEFFOUT
COMBVCF="../$FINALVCF/$PREFIX.$SET.selected.SNP.vcf.gz ../$FINALVCF/$PREFIX.$SET.selected.INDEL.vcf.gz"

for n in $COMBVCF
do
 st=$(echo $n | perl -p -e 's/\.gz//')
 if [ ! -f $n ]; then
	 bgzip $st
	 tabix $n
 fi
done
INVCF=$PREFIX.$SET.combined_selected.SNP.vcf
OUTVCF=$PREFIX.$SET.snpEff.vcf
OUTTAB=$PREFIX.$SET.snpEff.tab
bcftools concat -a -d both -o $INVCF -O v $COMBVCF
java -Xmx$MEM -jar $SNPEFFJAR eff -dataDir `pwd`/data -v $SNPEFFGENOME $INVCF > $OUTVCF

#bcftools query -H -f '%CHROM\t%POS\t%REF\t%ALT{0}[\t%TGT]\t%INFO/ANN\n' $OUTVCF > $OUTTAB

module unload python
module load python/2.7.12

python ../scripts/snpEff_to_table.py $PREFIX.$SET.snpEff.vcf ../$FASTAGENOMEFILE > $PREFIX.$SET.snpEff.tab2
cd ../
done
