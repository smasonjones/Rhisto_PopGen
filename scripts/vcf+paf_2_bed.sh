#!/usr/bin/bash
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --mem 16G -p short
#SBATCH --job-name=Ref_Transform
#SBATCH --time=2:00:00
#SBATCH --output=logs/Ref_Transform.%A.log


module load bedops
module load minimap2
module unload python
module load python/2.7.12

VARIANTFOLDER=vcf_down_70
SET=AB
#FILTER=.selected.INDEL.lungonly
FILTER=.filtered.SNP
ASM=asm20

convert2bed --input=VCF < $VARIANTFOLDER/ClusNanoL1B_201906.$SET$FILTER.vcf >  $VARIANTFOLDER/ClusNanoL1B_201906.$SET$FILTER.bed
paftools.js liftover ATCCxL1B.$ASM.paf  $VARIANTFOLDER/ClusNanoL1B_201906.$SET$FILTER.bed >  $VARIANTFOLDER/ClusNanoL1B_201906.$SET$FILTER.$ASM.convert.bed
python scripts/ref_transform.py  $VARIANTFOLDER/ClusNanoL1B_201906.$SET$FILTER.vcf   $VARIANTFOLDER/ClusNanoL1B_201906.$SET$FILTER.$ASM.convert.bed
