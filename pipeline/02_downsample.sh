#!/usr/bin/bash
#SBATCH --mem 32G --ntasks 4 --nodes 1 -J Downsample
#SBATCH --out logs/down.%a.log --time 12:00:00


module load samtools

N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
 N=$1
fi

if [ ! $N ]; then
 echo "need to provide a number by --array slurm or on the cmdline"
 exit
fi

DOWN=100
ALNFILE=$(cat bam_list.txt | sed -n ${N}p)
HTCEXT=bam
HTCFORMAT=bam
STRAIN=$(basename $ALNFILE .bam)
ALNFOLDER=bam_down_$DOWN
#ALNFOLDER=bam_down_70

ALNFILE="$STRAIN.bam"

#samtools depth $ALNFILE  |  awk '{sum+=$3} END { print "Average = ",sum/NR}' > $ALNFILE.cov

        cov=$(samtools depth  $ALNFOLDER/$ALNFILE  |  awk '{sum+=$3} END { print sum/NR}')
        echo $ALNFILE $STRAIN $cov
	echo $ALNFILE $STRAIN $cov >  $ALNFOLDER/$ALNFILE.cov

       # samtools view -b -s $(awk "BEGIN{print 2 / $cov}") -@ N -O $HTCFORMAT -o $ALNFOLDER/${STRAIN}.2.$HTCEXT $ALNFOLDER/$ALNFILE
        #samtools view -b -s $(awk "BEGIN{print 5 / $cov}") -@ N -O $HTCFORMAT -o $ALNFOLDER/${STRAIN}.5.$HTCEXT $ALNFILE

        int=${cov%.*}
        echo $int
       if [ "$int" -gt "$DOWN" ]; then
        #if [ "$int" -gt "$75" ]; then
        awk "BEGIN{print $DOWN / $cov}"
        samtools view -b -s $(awk "BEGIN{print $DOWN / $cov}") -@ N -O $HTCFORMAT -o $ALNFOLDER/${STRAIN}.down.$HTCEXT  $ALNFOLDER/$ALNFILE
	mv  $ALNFOLDER/$ALNFILE  $ALNFOLDER/$ALNFILE.old
	mv $ALNFOLDER/${STRAIN}.down.$HTCEXT  $ALNFOLDER/$ALNFILE
	samtools index  $ALNFOLDER/$ALNFILE
	
        fi

