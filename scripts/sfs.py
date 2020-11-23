#removes fixed (ie non segregating) variants. Compared to the other script, this one does not include sites that are an unknown call
import sys
import vcf.parser


if len(sys.argv) < 2:
	print "Usage removedfixed.py infile.SNPSONLY.vcf"



vcf_reader = vcf.Reader(open(sys.argv[1], 'r'))

for record in vcf_reader:
	print record.num_hom_alt
