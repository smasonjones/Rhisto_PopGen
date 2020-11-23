#removes fixed (ie non segregating) variants. Compared to the other script, this one does not include sites that are an unknown call. This requires PyVCF and Python version 2.7.12 
import sys
import vcf.parser
import os

if len(sys.argv) < 3:
	print "Usage combine_nocalls.py vcf_folder sorted_samples.txt"

samp_arr=[]
title = ''
for sample in open(sys.argv[2],'r'):
	samp_arr.append(sample.strip())
	title+= '\t' + sample.strip()
print title
total_dict={}
for file in os.listdir(sys.argv[1]):
    if file.endswith(".vcf"):
        # os.path.join will combine multiple names into a full path
        filename=os.path.join(sys.argv[1], file)

	vcf_reader = vcf.Reader(open(filename, 'r'))
	dict={}
	
	new = 0
	total_variants=0
	for record in vcf_reader:
		unknowns=record.get_unknowns()
		total_variants+=1
		for unknown in unknowns:
			sample=unknown.sample
#			print sample
			if sample not in dict:
				dict[unknown.sample]=0
			else:
				dict[unknown.sample]+=1
			if sample not in total_dict:
                                total_dict[unknown.sample]=0
	#			new = 1
                        else:
                                total_dict[unknown.sample]+=1
			
	report = file
	#title = 'Samples'

	for key in samp_arr:
	#	title +='\t' + key
		if key not in dict:
			report += '\t0'
		else:
			report +='\t' + str(dict[key]/float(total_variants))
	#if new == 1:
#		print title
	print report

