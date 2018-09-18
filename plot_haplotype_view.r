library(ggplot2); library(reshape2); library(gplots); library(RColorBrewer)
# visualize the genotypes (SNPs) surrounding domestication gene

# load pop label file
pop<-read.table("HAPLOTYPE_VIEW/pop.list")
pop$V2<-factor(pop$V2,levels=c("white","OB_W","OB_G","OG_A1","OG_A2","OG_B","OG_C1","OG_C2")); pop$V1<-as.character(pop$V1)
colorscheme=data.frame(V1=c("white","#FFFF33","#F781BF","#984EA3","#377EB8","#FF7F00","#4DAF4A","#A65628"),V2=c("white","OB_W","OB_G","OG_A1","OG_A2","OG_B","OG_C1","OG_C2"))
pop<-pop[!pop$V2=="white",]; pop$V2<-droplevels(pop$V2)

# load genotype file
# sh4
df<-read.table("HAPLOTYPE_VIEW/ORGLA04G0254300_sh4_region_chr4_25125788_25177622_25kbpPadded.haplotype.txt",h=T); 
pop<-pop[order(pop$V1),]; df$NAME=as.character(df$NAME); df<-df[match(pop$V1,df$NAME),];

# get coord for gene of interest
GENESTART=25150788; GENEEND=25152622; #sh4

# highlight region of interest
ALLCOORD<-as.numeric(gsub("X", "", colnames(df)[-1]))
geneSNP<-ifelse(ALLCOORD>GENESTART & ALLCOORD<GENEEND,"red","white")

# cluster within populations
hclist<-c()
for (i in 1:nlevels(pop$V2)) {
        hc<-hclust(dist(data.matrix(df[pop$V2==levels(pop$V2)[i],-1])))
        hclist<-c(hclist,as.character(df[pop$V2==levels(pop$V2)[i],]$NAME[hc$order]))
}

# visualize genotypes
df<-df[match(hclist,df$NAME),]; pop<-pop[match(hclist,pop$V1),]
mat<-data.matrix(df[,-1]); rownames(mat)<-df[,1]; mat[mat < 0] <- NA
heatmap.2(mat,
        col=c("grey63","grey33","grey3"),
        #col=c("grey63","grey33","grey3","red"),
        Rowv = NA,
        Colv = NA,
        RowSideColors=as.character(colorscheme$V1[match(pop$V2,colorscheme$V2)]),
        ColSideColors=as.character(geneSNP),
        lhei=c(1,5),lwid=c(1,5),
        density.info="none",trace="none",symm = FALSE,dendrogram='none',scale='none',labRow=NA,labCol=NA,key=FALSE
)
