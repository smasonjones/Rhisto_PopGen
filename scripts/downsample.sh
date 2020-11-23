#!/usr/bin/bash
#SBATCH --mem 64G --ntasks 12 --nodes 1 -J Downsample
#SBATCH --out logs/down.%a.log --time 1-12:00:00


module load samtools

N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
 N=$1
fi

if [ ! $N ]; then
 echo "need to provide a number by --array slurm or on the cmdline"
 exit
fi


ALNFILE=$(ls bam/*.bam | sed -n ${N}p)
HTCEXT=bam
HTCFORMAT=bam
STRAIN=$(basename $ALNFILE .bam)



samtools depth $ALNFILE  |  awk '{sum+=$3} END { print "Average = ",sum/NR}' > $ALNFILE.cov

	 cov=$(samtools depth $ALNFILE  |  awk '{sum+=$3} END { print sum/NR}')
        echo $ALNFILE $STRAIN $cov 
        ALNFOLDER=bam_down

        samtools view -b -s $(awk "BEGIN{print 2 / $cov}") -@ N -O $HTCFORMAT -o $ALNFOLDER/${STRAIN}.2.$HTCEXT $ALNFILE
        samtools view -b -s $(awk "BEGIN{print 5 / $cov}") -@ N -O $HTCFORMAT -o $ALNFOLDER/${STRAIN}.5.$HTCEXT $ALNFILE
	
	int=${cov%.*}
	echo $int
	for ((i=10;i<=$int;i=i+10)); do
	awk "BEGIN{print $i/$cov}"
        samtools view -b -s $(awk "BEGIN{print $i / $cov}") -@ N -O $HTCFORMAT -o $ALNFOLDER/${STRAIN}.$i.$HTCEXT $ALNFILE
        done
