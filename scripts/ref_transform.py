#!usr/bin/python
import sys
import vcf.parser


if len(sys.argv) < 2:
        print "Usage ref_transform.py infile.SNPSONLY.vcf converted.bed"


newfilename = sys.argv[2].rstrip('bed')
newfile =  newfilename + "trans.vcf"

vcf_reader = vcf.Reader(open(sys.argv[1], 'r'))
vcf_writer = vcf.Writer(open(newfile,'w'),vcf_reader)
for vcf_record in vcf_reader:
	bed_reader = open(sys.argv[2],'r')
	for bed_record in bed_reader:
		rec_arr=bed_record.split()
		old_coord=rec_arr[3].split('_')
		
		old_chrom = old_coord[0] + "_" + old_coord[1]
#		print old_chrom + " " + old_coord[3] + " " + vcf_record.CHROM + " " + str(vcf_record.POS)
		if (int(old_coord[3]) == vcf_record.POS) and (old_chrom == vcf_record.CHROM):
#			print "HIT"
			new_record = vcf_record
        		new_record.CHROM = rec_arr[0]
        		new_record.POS = rec_arr[1]
        		vcf_writer.write_record(new_record)
	bed_reader.close()			
vcf_writer.close()

