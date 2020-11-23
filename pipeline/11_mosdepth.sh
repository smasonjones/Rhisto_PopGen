#!/bin/bash
#SBATCH --nodes 1 --ntasks 24 --time 2:00:00 -p short --mem 64G --out mosdepth.parallel.log
#SBATCH -J modepth
module load parallel
CPU=$SLURM_CPUS_ON_NODE
if [ ! $CPU ]; then
 CPU=2
fi
module unload perl
module unload python/2.7.5
module load mosdepth
mkdir -p coverage/mosdepth
source config.txt

WINDOW=5000
parallel --jobs $CPU mosdepth -f $REFGENOME -T 1,10,50,100,200 -n --by $WINDOW -t 2 "{= s:bam\/:coverage/mosdepth/:; s:\.bam:.${WINDOW}bp: =}" {} ::: bam/*.bam

WINDOW=10000
parallel --jobs $CPU mosdepth -f $REFGENOME -T 1,10,50,100,200 -n --by $WINDOW -t 2 "{= s:bam\/:coverage/mosdepth/:; s:\.bam:.${WINDOW}bp: =}" {} ::: bam/*.bam

WINDOW=20000
parallel --jobs $CPU mosdepth -f $REFGENOME -T 1,10,50,100,200 -n --by $WINDOW -t 2 "{= s:bam\/:coverage/mosdepth/:; s:\.bam:.${WINDOW}bp: =}" {} ::: bam/*.bam

bash scripts/mosdepth_prep_ggplot.sh
mkdir -p plots
Rscript Rscripts/plot_mosdepth_CNV.R
