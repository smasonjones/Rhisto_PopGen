#!/usr/bin/bash
#SBATCH --nodes 1
#SBATCH --ntasks 16
#SBATCH --mem=96G
#SBATCH --job-name=GATK.GVCFGeno
#SBATCH --output=logs/GATK.GVCFGeno.%A_%a.log
#SBATCH --time=12:00:00

#Takes each individual sample vcf from Haplotype Caller step and combines it into single, combined vcf
MEM=96g #Requires large amount of memory. Adjust according to existing resources
module load picard
module load bcftools
module load gatk/3.8
CONFIG=config.txt
SAMPFILE=setlist.txt
TEMP=/scratch
if [ -f $CONFIG ]; then
    source $CONFIG
else
        echo "Expected a config file $CONFIG"
        exit
fi

N=${SLURM_ARRAY_TASK_ID}
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi


if [ -z $N ]; then
 N=$1
fi

if [ -z $N ]; then
 echo "need to provide a number by --array or cmdline"
 exit
fi

MAX=$(wc -l $SAMPFILE | awk '{print $1}')
echo "$N $MAX for $SAMPFILE"
if [ $N -gt $MAX ]; then
 echo "$N is too big, only $MAX lines in $SAMPFILE"
 exit
fi

IFS=$'\t'
cat $SAMPFILE | sed -n ${N}p | while read SET SAMPLES
do
 OUT=$FINALVCF/$PREFIX.$SET.vcf
 V=$(echo "$SAMPLES" | perl -p -e  's/[\r\n]+$//;')

if [ -f $CONFIG ]; then
    source $CONFIG
else
	echo "Expected a config file $CONFIG"
	exit
fi
GENOMEIDX=$GENOMEFOLDER/$GENOMEFASTA
KNOWNSITES=
#OUT=$FINALVCF/$PREFIX.Evol.vcf
mkdir -p $FINALVCF
CPU=1

if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi
if [[ $(ls $VARIANTFOLDER/*.g.vcf | wc -l | awk '{print $1}') -gt "0" ]]; then
	parallel -j 16 bgzip {} ::: $VARIANTFOLDER/*.g.vcf
	parallel -j 16 tabix -f {} ::: $VARIANTFOLDER/*.g.vcf.gz
fi

#N=$(ls $VARIANTFOLDER/*g.vcf.gz | sort | grep -v $VARIANTFOLDER/ATCC | grep $VARIANTFOLDER/B | grep -v CL | grep -v CBS | perl -p -e 's/\n/ /; s/(\S+)/-V:VCF $1/') #Lists each sample vcf by -V sample1.vcf -V sample2.vcf...
#N= -V:VCF gvcf/A2.U10.g.vcf.gz  -V:VCF gvcf/AA3.U3G.g.vcf.gz -V:VCF gvcf/A4.U3B.g.vcf.gz -V:VCF gvcf/A5.U10D.g.vcf.gz -V:VCF gvcf/A6.U5C.g.vcf.gz -V:VCF gvcf/A7.U3E.g.vcf.gz -V:VCF gvcf/A8.U2E.g.vcf.gz -V:VCF gvcf/A9.L3D.g.vcf.gz -V:VCF gvcf/A10.L4C.g.vcf.gz -V:VCF gvcf/A11.L11G.g.vcf.gz -V:VCF gvcf/A12.L10B.g.vcf.gz -V:VCF gvcf/A13.L3B.g.vcf.gz -V:VCF gvcf/A14.L4E.g.vcf.gz -V:VCF gvcf/A15.L4G.g.vcf.gz -V:VCF gvcf/A16.L7C.g.vcf.gz -V:VCF gvcf/A17.L1B.g.vcf.gz -V:VCF gvcf/A18.S4H.g.vcf.gz -V:VCF gvcf/A19.S3B.g.vcf.gz -V:VCF gvcf/A20.S1E.g.vcf.gz -V:VCF gvcf/A21.S8A.g.vcf.gz -V:VCF gvcf/A_Sp2_12C.g.vcf.gz -V:VCF gvcf/A_Sp2_1B.g.vcf.gz -V:VCF gvcf/A_Sp2_1G.g.vcf.gz -V:VCF gvcf/A_Sp2_8D.g.vcf.gz -V:VCF gvcf/ctl1.AL1B.g.vcf.gz -V:VCF gvcf/ctl2.AL1B.g.vcf.gz
#N= -V:VCF gvcf/13_BAL_3B.g.vcf.gz -V:VCF gvcf/13_BAL_5F.g.vcf.gz -V:VCF gvcf/13_BAL_6C.g.vcf.gz -V:VCF gvcf/13_BAL_6E.g.vcf.gz -V:VCF gvcf/13_sp2017_3D.g.vcf.gz -V:VCF gvcf/13_sp2017_6G.g.vcf.gz -V:VCF gvcf/B16.1310D.g.vcf.gz -V:VCF gvcf/B17.1311G.g.vcf.gz -V:VCF gvcf/B18.1312G.g.vcf.gz -V:VCF gvcf/B19.1310A.g.vcf.gz -V:VCF gvcf/B20.1311A.g.vcf.gz -V:VCF gvcf/B21.1312A.g.vcf.gz -V:VCF gvcf/B22.134E.g.vcf.gz -V:VCF gvcf/B23.133H.g.vcf.gz -V:VCF gvcf/B24.133F.g.vcf.gz -V:VCF gvcf/B25.135C.g.vcf.gz -V:VCF gvcf/B26.131A.g.vcf.gz -V:VCF gvcf/B27.136A.g.vcf.gz 
#N= -V:VCF gvcf/C10.9M3.g.vcf.gz -V:VCF gvcf/C11.9M41.g.vcf.gz -V:VCF gvcf/C12.9U1.g.vcf.gz -V:VCF gvcf/C13.9U2.g.vcf.gz -V:VCF gvcf/C14.9U3.g.vcf.gz -V:VCF gvcf/C15.9U4s.g.vcf.gz -V:VCF gvcf/C4.9L1.g.vcf.gz -V:VCF gvcf/C5.9L2.g.vcf.gz -V:VCF gvcf/C6.9L3.g.vcf.gz -V:VCF gvcf/C7.9L4.g.vcf.gz -V:VCF gvcf/C8.9M1.g.vcf.gz -V:VCF gvcf/C9.9M2.g.vcf.gz -V:VCF gvcf/ctl3.C9L1.g.vcf.gz
#N= -V:VCF gvcf/ATCC42720.g.vcf.gz  -V:VCF gvcf/CBS_6936.g.vcf.gz  -V:VCF gvcf/CL_AR0398.g.vcf.gz -V:VCF gvcf/Phaff_16_4994_55.g.vcf.gz -V:VCF gvcf/Phaff_61_4.g.vcf.gz -V:VCF gvcf/Phaff_71_129.g.vcf.gz -V:VCF gvcf/Phaff_76_31.g.vcf.gz -V:VCF gvcf/Phaff_79_1.g.vcf.gz -V:VCF gvcf/Phaff_80_11.g.vcf.gz -V:VCF gvcf/Phaff_80_12.g.vcf.gz -V:VCF gvcf/Phaff_82_606_2.g.vcf.gz -V:VCF gvcf/A17.L1B.g.vcf.gz -V:VCF gvcf/C4.9L1.g.vcf.gz -V:VCF gvcf/B16.1310D.g.vcf.gz -V:VCF gvcf/CL_1A.g.vcf.gz
#N= -V:VCF gvcf/CL_10.g.vcf.gz -V:VCF gvcf/CL_14.g.vcf.gz -V:VCF gvcf/CL_17.g.vcf.gz -V:VCF gvcf/A17.L1B.g.vcf.gz -V:VCF gvcf/CL_2383.g.vcf.gz -V:VCF gvcf/CL_7.g.vcf.gz
#N=  -V:VCF gvcf/13_BAL_6C.g.vcf.gz -V:VCF gvcf/Evol_MG1_6C_L2.g.vcf.gz -V:VCF gvcf/Evol_MG2_6C_L1.g.vcf.gz
#N= -V:VCF gvcf/L1B_MATa_ura.g.vcf.gz -V:VCF gvcf/A17.L1B.g.vcf.gz -V:VCF gvcf/ctl1.AL1B.g.vcf.gz -V:VCF gvcf/ctl2.AL1B.g.vcf.gz
#N=  -V:VCF gvcf/A5.U10D.g.vcf.gz -V:VCF gvcf/U10Dmrr1.g.vcf.gz
#N= -V:VCF gvcf/A4.U3B.g.vcf.gz -V:VCF gvcf/A5.U10D.g.vcf.gz -V:VCF gvcf/Evol_1_p7_W1.g.vcf.gz -V:VCF gvcf/Evol_3_p7_W1.g.vcf.gz -V:VCF gvcf/Evol_4_p7_W2.g.vcf.gz -V:VCF gvcf/Evol_5_p7_W2.g.vcf.gz
echo $V


java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOMEIDX \
    $V \
    --max_alternate_alleles 3 \
    -o $OUT \
    -nt $CPU  
done
