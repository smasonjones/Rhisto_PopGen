#!/usr/bin/bash

#SBATCH --mem=8gb --ntasks 1 --nodes 1
#SBATCH --time=2:00:00 -p  short
#SBATCH -J combined_nocalls --out logs/combine_nocalls.%A.log



module unload python
module load python/2.7.12

python scripts/combine_no_calls.py vcf_recal/ sorted_samples.txt > vcf_recal/nocalls.tab
