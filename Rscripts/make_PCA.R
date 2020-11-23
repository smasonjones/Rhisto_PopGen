
library(gdsfmt)
library(SNPRelate)

vcf.fn <- "vcf_recal_sub/Rhisto1.all.selected.SNP.vcf.gz"
snpgdsVCF2GDS(vcf.fn, "Rhisto1.all.selected.SNP.gds",
method="biallelic.only")
snpgdsSummary("Rhisto1.all.selected.SNP.gds")

genofile <- snpgdsOpen("Rhisto1.all.selected.SNP.gds")
pca <- snpgdsPCA(genofile,num.thread=2,autosome.only=FALSE)
pc.percent <- pca$varprop*100
head(round(pc.percent, 2))

# read in phenotypes
pheno <- read.csv("phenotypes.good.csv",header=TRUE)
#pheno <- read.csv("metadata.csv",header=TRUE)

# make a data frame of all the data for the plotting
tab <- data.frame(sample.id = pca$sample.id,
pop = pheno[,2], # population info is 3rd column (location) in pheno.csv
EV1=pca$eigenvect[,1], # PCA vector 2 
EV2=pca$eigenvect[,2], # PCA vector 3
stringsAsFactors=FALSE)

head(pca$varprop[2])

png("PCA_Substrate.noout.1v2.png")
plot(tab$EV2, tab$EV1, col=as.integer(tab$pop), 
xlab=sprintf("eigenvector 2 %.2f%%",pca$varprop[2]*100),
ylab=sprintf("eigenvector 1 %.2f%%",pca$varprop[1]*100))

tab$pop
legend("topright", legend=levels(tab$pop), pch="o", col=1:nlevels(tab$pop))

tab <- data.frame(sample.id = pca$sample.id,
pop = pheno[,2], # population info is 3rd column (location) in pheno.csv
EV1=pca$eigenvect[,2], # PCA vector 2
EV2=pca$eigenvect[,3], # PCA vector 3
stringsAsFactors=FALSE)

head(pca$varprop[2])

png("PCA_Substrate.noout.2v3.png")
plot(tab$EV2, tab$EV1, col=as.integer(tab$pop),
xlab=sprintf("eigenvector 3 %.2f%%",pca$varprop[3]*100),
ylab=sprintf("eigenvector 2 %.2f%%",pca$varprop[2]*100))

legend("topright", legend=levels(tab$pop), pch="o",
col=1:nlevels(tab$pop))

tab <- data.frame(sample.id = pca$sample.id,
pop = pheno[,2], # population info is 3rd column (location) in pheno.csv
EV1=pca$eigenvect[,1], # PCA vector 2
EV2=pca$eigenvect[,3], # PCA vector 3
stringsAsFactors=FALSE)

head(pca$varprop[2])

png("PCA_Substrate.noout.1v3.png")
plot(tab$EV2, tab$EV1, col=as.integer(tab$pop),
xlab=sprintf("eigenvector 3 %.2f%%",pca$varprop[3]*100),
ylab=sprintf("eigenvector 1 %.2f%%",pca$varprop[1]*100))

legend("topright", legend=levels(tab$pop), pch="o",
col=1:nlevels(tab$pop))

# make a data frame of all the data for the plotting
tab <- data.frame(sample.id = pca$sample.id,
pop = pheno[,3], # population info is 3rd column (location) in pheno.csv
EV1=pca$eigenvect[,1], # PCA vector 1
EV2=pca$eigenvect[,2], # PCA vector 2
stringsAsFactors=FALSE)


png("PCA_Region.noout.1v2.png")
plot(tab$EV2, tab$EV1, col=as.integer(tab$pop),
xlab=sprintf("eigenvector 2 %.2f%%",pca$varprop[2]*100),
ylab=sprintf("eigenvector 1 %.2f%%",pca$varprop[1]*100))

# make a data frame of all the data for the plotting
tab <- data.frame(sample.id = pca$sample.id,
pop = pheno[,3], # population info is 3rd column (location) in pheno.csv
EV1=pca$eigenvect[,2], # PCA vector 1
EV2=pca$eigenvect[,3], # PCA vector 2
stringsAsFactors=FALSE)


png("PCA_Region.noout.2v3.png")
plot(tab$EV2, tab$EV1, col=as.integer(tab$pop),
xlab=sprintf("eigenvector 3 %.2f%%",pca$varprop[3]*100),
ylab=sprintf("eigenvector 2 %.2f%%",pca$varprop[2]*100))

# make a data frame of all the data for the plotting
tab <- data.frame(sample.id = pca$sample.id,
pop = pheno[,3], # population info is 3rd column (location) in pheno.csv
EV1=pca$eigenvect[,3], # PCA vector 1
EV2=pca$eigenvect[,4], # PCA vector 2
stringsAsFactors=FALSE)


png("PCA_Region.noout.3v4.png")
plot(tab$EV2, tab$EV1, col=as.integer(tab$pop),
xlab=sprintf("eigenvector 4 %.2f%%",pca$varprop[4]*100),
ylab=sprintf("eigenvector 3 %.2f%%",pca$varprop[3]*100))


# make a data frame of all the data for the plotting
tab <- data.frame(sample.id = pca$sample.id,
pop = pheno[,3], # population info is 3rd column (location) in pheno.csv
EV1=pca$eigenvect[,1], # PCA vector 1
EV2=pca$eigenvect[,3], # PCA vector 2
stringsAsFactors=FALSE)


png("PCA_Region.noout.3v1.png")
plot(tab$EV2, tab$EV1, col=as.integer(tab$pop), 
xlab=sprintf("eigenvector 3 %.2f%%",pca$varprop[3]*100),
ylab=sprintf("eigenvector 1 %.2f%%",pca$varprop[1]*100))

legend("topright", legend=levels(tab$pop), pch="o", 
col=1:nlevels(tab$pop))





