#!/usr/bin/bash
#SBATCH --nodes 1
#SBATCH --ntasks 16
#SBATCH --mem=96G
#SBATCH --job-name=GATK.GVCFGeno
#SBATCH --output=logs/GATK.GVCFGeno.%A.log
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
FINALVCF=vcf_force
OUT=$FINALVCF/$PREFIX.B.vcf
VARIANTFOLDER=gvcf_force
mkdir -p $FINALVCF
CPU=1

if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi
if [[ $(ls $VARIANTFOLDER/*.g.vcf | wc -l | awk '{print $1}') -gt "0" ]]; then
	parallel -j 16 bgzip {} ::: $VARIANTFOLDER/*.g.vcf
	parallel -j 16 tabix -f {} ::: $VARIANTFOLDER/*.g.vcf.gz
fi

N=$(ls $VARIANTFOLDER/*g.vcf.gz | sort | perl -p -e 's/\n/ /; s/(\S+)/-V:VCF $1/') #Lists each sample vcf by -V sample1.vcf -V sample2.vcf...
OUT=$FINALVCF/$PREFIX.all.vcf
java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOMEIDX \
    $N \
    --max_alternate_alleles 3  \
    -o $OUT \
    -nt $CPU


N='-V:VCF gvcf_force/A2.U10A.g.vcf.gz  -V:VCF gvcf_force/A3.U3G.g.vcf.gz -V:VCF gvcf_force/A4.U3B.g.vcf.gz -V:VCF gvcf_force/A5.U10D.g.vcf.gz -V:VCF gvcf_force/A6.U5C.g.vcf.gz -V:VCF gvcf_force/A7.U3E.g.vcf.gz -V:VCF gvcf_force/A8.U2E.g.vcf.gz -V:VCF gvcf_force/A9.L3D.g.vcf.gz -V:VCF gvcf_force/A10.L4C.g.vcf.gz -V:VCF gvcf_force/A11.L11G.g.vcf.gz -V:VCF gvcf_force/A12.L10B.g.vcf.gz -V:VCF gvcf_force/A13.L3B.g.vcf.gz -V:VCF gvcf_force/A14.L4E.g.vcf.gz -V:VCF gvcf_force/A15.L4G.g.vcf.gz -V:VCF gvcf_force/A16.L7C.g.vcf.gz -V:VCF gvcf_force/A17.L1B.g.vcf.gz -V:VCF gvcf_force/A18.S4H.g.vcf.gz -V:VCF gvcf_force/A19.S3B.g.vcf.gz -V:VCF gvcf_force/A20.S1E.g.vcf.gz -V:VCF gvcf_force/A21.S8A.g.vcf.gz -V:VCF gvcf_force/A_Sp2_12C.g.vcf.gz -V:VCF gvcf_force/A_Sp2_1B.g.vcf.gz -V:VCF gvcf_force/A_Sp2_1G.g.vcf.gz -V:VCF gvcf_force/A_Sp2_8D.g.vcf.gz -V:VCF gvcf_force/ctl1.AL1B.g.vcf.gz -V:VCF gvcf_force/ctl2.AL1B.g.vcf.gz -V:VCF gvcf_force/13_BAL_3B.g.vcf.gz -V:VCF gvcf_force/13_BAL_5F.g.vcf.gz -V:VCF gvcf_force/13_BAL_6C.g.vcf.gz -V:VCF gvcf_force/13_BAL_6E.g.vcf.gz -V:VCF gvcf_force/13_sp2017_3D.g.vcf.gz -V:VCF gvcf_force/13_sp2017_6G.g.vcf.gz -V:VCF gvcf_force/B16.1310D.g.vcf.gz -V:VCF gvcf_force/B17.1311G.g.vcf.gz -V:VCF gvcf_force/B18.1312G.g.vcf.gz -V:VCF gvcf_force/B19.1310A.g.vcf.gz -V:VCF gvcf_force/B20.1311A.g.vcf.gz -V:VCF gvcf_force/B21.1312A.g.vcf.gz -V:VCF gvcf_force/B22.134E.g.vcf.gz -V:VCF gvcf_force/B23.133H.g.vcf.gz -V:VCF gvcf_force/B24.133F.g.vcf.gz -V:VCF gvcf_force/B25.135C.g.vcf.gz -V:VCF gvcf_force/B26.131A.g.vcf.gz -V:VCF gvcf_force/B27.136A.g.vcf.gz'
OUT=$FINALVCF/$PREFIX.AB.vcf

java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOMEIDX \
    $N \
    --max_alternate_alleles 3  \
    -o $OUT \
    -nt $CPU


N='-V:VCF gvcf_force/A2.U10A.g.vcf.gz  -V:VCF gvcf_force/A3.U3G.g.vcf.gz -V:VCF gvcf_force/A4.U3B.g.vcf.gz -V:VCF gvcf_force/A5.U10D.g.vcf.gz -V:VCF gvcf_force/A6.U5C.g.vcf.gz -V:VCF gvcf_force/A7.U3E.g.vcf.gz -V:VCF gvcf_force/A8.U2E.g.vcf.gz -V:VCF gvcf_force/A9.L3D.g.vcf.gz -V:VCF gvcf_force/A10.L4C.g.vcf.gz -V:VCF gvcf_force/A11.L11G.g.vcf.gz -V:VCF gvcf_force/A12.L10B.g.vcf.gz -V:VCF gvcf_force/A13.L3B.g.vcf.gz -V:VCF gvcf_force/A14.L4E.g.vcf.gz -V:VCF gvcf_force/A15.L4G.g.vcf.gz -V:VCF gvcf_force/A16.L7C.g.vcf.gz -V:VCF gvcf_force/A17.L1B.g.vcf.gz -V:VCF gvcf_force/A18.S4H.g.vcf.gz -V:VCF gvcf_force/A19.S3B.g.vcf.gz -V:VCF gvcf_force/A20.S1E.g.vcf.gz -V:VCF gvcf_force/A21.S8A.g.vcf.gz -V:VCF gvcf_force/A_Sp2_12C.g.vcf.gz -V:VCF gvcf_force/A_Sp2_1B.g.vcf.gz -V:VCF gvcf_force/A_Sp2_1G.g.vcf.gz -V:VCF gvcf_force/A_Sp2_8D.g.vcf.gz -V:VCF gvcf_force/ctl1.AL1B.g.vcf.gz -V:VCF gvcf_force/ctl2.AL1B.g.vcf.gz'
OUT=$FINALVCF/$PREFIX.A.vcf

java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOMEIDX \
    $N \
    --max_alternate_alleles 3  \
    -o $OUT \
    -nt $CPU


N='-V:VCF gvcf_force/13_BAL_3B.g.vcf.gz -V:VCF gvcf_force/13_BAL_5F.g.vcf.gz -V:VCF gvcf_force/13_BAL_6C.g.vcf.gz -V:VCF gvcf_force/13_BAL_6E.g.vcf.gz -V:VCF gvcf_force/13_sp2017_3D.g.vcf.gz -V:VCF gvcf_force/13_sp2017_6G.g.vcf.gz -V:VCF gvcf_force/B16.1310D.g.vcf.gz -V:VCF gvcf_force/B17.1311G.g.vcf.gz -V:VCF gvcf_force/B18.1312G.g.vcf.gz -V:VCF gvcf_force/B19.1310A.g.vcf.gz -V:VCF gvcf_force/B20.1311A.g.vcf.gz -V:VCF gvcf_force/B21.1312A.g.vcf.gz -V:VCF gvcf_force/B22.134E.g.vcf.gz -V:VCF gvcf_force/B23.133H.g.vcf.gz -V:VCF gvcf_force/B24.133F.g.vcf.gz -V:VCF gvcf_force/B25.135C.g.vcf.gz -V:VCF gvcf_force/B26.131A.g.vcf.gz -V:VCF gvcf_force/B27.136A.g.vcf.gz'
OUT=$FINALVCF/$PREFIX.B.vcf

java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOMEIDX \
    $N \
    --max_alternate_alleles 3  \
    -o $OUT \
    -nt $CPU



N=' -V:VCF gvcf_force/C10.9M3.g.vcf.gz -V:VCF gvcf_force/C11.9M41.g.vcf.gz -V:VCF gvcf_force/C12.9U1.g.vcf.gz -V:VCF gvcf_force/C13.9U2.g.vcf.gz -V:VCF gvcf_force/C14.9U3.g.vcf.gz -V:VCF gvcf_force/C15.9U4s.g.vcf.gz -V:VCF gvcf_force/C4.9L1.g.vcf.gz -V:VCF gvcf_force/C5.9L2.g.vcf.gz -V:VCF gvcf_force/C6.9L3.g.vcf.gz -V:VCF gvcf_force/C7.9L4.g.vcf.gz -V:VCF gvcf_force/C8.9M1.g.vcf.gz -V:VCF gvcf_force/C9.9M2.g.vcf.gz -V:VCF gvcf_force/ctl3.C9L1.g.vcf.gz'
OUT=$FINALVCF/$PREFIX.C.vcf

java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOMEIDX \
    $N \
    --max_alternate_alleles 3  \
    -o $OUT \
    -nt $CPU


N=' -V:VCF gvcf_force/ATCC42720.g.vcf.gz  -V:VCF gvcf_force/CBS_6936.g.vcf.gz  -V:VCF gvcf_force/CL_AR0398.g.vcf.gz -V:VCF gvcf_force/Phaff_16_4994_55.g.vcf.gz -V:VCF gvcf_force/Phaff_61_4.g.vcf.gz -V:VCF gvcf_force/Phaff_71_129.g.vcf.gz -V:VCF gvcf_force/Phaff_76_31.g.vcf.gz -V:VCF gvcf_force/Phaff_79_1.g.vcf.gz -V:VCF gvcf_force/Phaff_80_11.g.vcf.gz -V:VCF gvcf_force/Phaff_80_12.g.vcf.gz -V:VCF gvcf_force/Phaff_82_606_2.g.vcf.gz -V:VCF gvcf_force/A17.L1B.g.vcf.gz -V:VCF gvcf_force/C4.9L1.g.vcf.gz -V:VCF gvcf_force/B16.1310D.g.vcf.gz -V:VCF gvcf_force/CL_1A.g.vcf.gz'
OUT=$FINALVCF/$PREFIX.minall.vcf

java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOMEIDX \
    $N \
    --max_alternate_alleles 3  \
    -o $OUT \
    -nt $CPU


N=' -V:VCF gvcf_force/CL_10.g.vcf.gz -V:VCF gvcf_force/CL_14.g.vcf.gz -V:VCF gvcf_force/CL_17.g.vcf.gz -V:VCF gvcf_force/A17.L1B.g.vcf.gz -V:VCF gvcf_force/CL_2383.g.vcf.gz -V:VCF gvcf_force/CL_7.g.vcf.gz'
OUT=$FINALVCF/$PREFIX.L1Bprog.vcf

java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOMEIDX \
    $N \
    --max_alternate_alleles 3  \
    -o $OUT \
    -nt $CPU



N=' -V:VCF gvcf_force/13_BAL_6C.g.vcf.gz -V:VCF gvcf_force/Evol_MG1_6C_L2.g.vcf.gz -V:VCF gvcf_force/Evol_MG2_6C_L1.g.vcf.gz'
OUT=$FINALVCF/$PREFIX.EvolB.vcf
java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOMEIDX \
    $N \
    --max_alternate_alleles 3  \
    -o $OUT \
    -nt $CPU


N=' -V:VCF gvcf_force/L1B_MATa_ura-.g.vcf.gz -V:VCF gvcf_force/A17.L1B.g.vcf.gz -V:VCF gvcf_force/ctl1.AL1B.g.vcf.gz -V:VCF gvcf_force/ctl2.AL1B.g.vcf.gz'
OUT=$FINALVCF/$PREFIX.L1Bmat.vcf
java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOMEIDX \
    $N \
    --max_alternate_alleles 3  \
    -o $OUT \
    -nt $CPU


N=' -V:VCF gvcf_force/A5.U10D.g.vcf.gz -V:VCF gvcf_force/U10Dmrr1.g.vcf.gz'
OUT=$FINALVCF/$PREFIX.MRR1delt.vcf
java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOMEIDX \
    $N \
    --max_alternate_alleles 3  \
    -o $OUT \
    -nt $CPU


N=' -V:VCF gvcf_force/A4.U3B.g.vcf.gz -V:VCF gvcf_force/A5.U10D.g.vcf.gz -V:VCF gvcf_force/Evol_1_p7_W1.g.vcf.gz -V:VCF gvcf_force/Evol_3_p7_W1.g.vcf.gz -V:VCF gvcf_force/Evol_4_p7_W2.g.vcf.gz -V:VCF gvcf_force/Evol_5_p7_W2.g.vcf.gz'
OUT=$FINALVCF/$PREFIX.EvolA.vcf
java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOMEIDX \
    $N \
    --max_alternate_alleles 3  \
    -o $OUT \
    -nt $CPU  
