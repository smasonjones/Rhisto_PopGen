#removes fixed (ie non segregating) variants. Compared to the other script, this one does not include sites that are an unknown call. This requires PyVCF and Python version 2.7.12 
import sys
import vcf.parser


if len(sys.argv) < 2:
	print "Usage removedfixed.py infile.SNPSONLY.vcf"



vcf_reader = vcf.Reader(open(sys.argv[1], 'r'))
dict={}

for record in vcf_reader:
	unknowns=record.get_unknowns()
	for unknown in unknowns:
		sample=unknown.sample
#		print sample
		if sample not in dict:
			dict[unknown.sample]=0
		else:
			dict[unknown.sample]+=1

report = 'No Calls'
title = 'Samples'
for key, value in dict.items()
	'\t'.join(report,value)
	'\t'.join(title,key)
	

print title
print report
