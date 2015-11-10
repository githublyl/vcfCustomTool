file<-commandArgs(TRUE)
if(length(file)!=2){
        stop("Rscript line.R chr.txt")
}

data<-read.table(file[1],header=T)

data<-read.table("chr.txt")
jpeg("all.chr.density.jpg")

filename<-""

for (i in 1:length(data$V1)){
        chr<-as.character(data[i,1])
        filename<-paste(chr,".below.500.tmp",sep="")
        dat<-read.table(filename,head=T)
        if(i ==1){
                plot(density(dat[,4]),col="grey",xlim=c(0,1000),ylim=c(0,1e10), main="Hetero SNP Density", xlab="Relative Distance",ylab="Frequency")
        }else{
#               par(new=T,xaxt='n',yaxt='n')
                lines(density(dat[,4]), col="grey",ylab="",xlab="",main="")
        }

}

dev.off()

name1<-paste(prefix,"1.jpg",sep=".")
name2<-paste(prefix,"2.jpg",sep=".")
jpeg(name1)
plot(density(data[,4]),main="hetero_snp_density",sub=prefix,xlab="Relative Distance",ylab="Frequency")
rug(data[,4])
dev.off()
jpeg(name2)
plot(density(data[,6]),main="hetero_snp_allele_frequency",xlab="allele frequency",ylab="Frequency")
dev.off()


