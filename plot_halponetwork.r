library(vcfR); library(pegas); library(RColorBrewer)

#### loading...
# accession and assigned group name from Choi et al.
LIST<-read.table("HaploNetwork/pop.list")
# load data
DF<-read.vcfR("sh1_5kbp_upstream.Obar_RefGenome.phased.vcf")
# custom color to match Choi et al.
color=brewer.pal(9,"Set1")[c(8,6,4,2,5,3,7)]
#####

# change data structure of VCF to DNAbin
DF<-vcfR2DNAbin(DF)
# select one of the two phased haplotype
DF<-DF[rownames(DF)[seq(1,length(rownames(DF)),2)],]
rownames(DF)<-gsub("_0","",rownames(DF))

### match the list order of DF or LIST with each other
## if DF has more individuals then LIST
#DF<-DF[match(LIST$V1,rownames(DF)),]
## OR if LIST has more individuals then DF
#LIST<-LIST[match(rownames(DF),LIST$V1),]
## change individuals name to group name
#LIST<-LIST[match(rownames(DF),as.character(LIST$V1)),]
# OR
#DF1<-DF; rownames(DF1)<-LIST$V2

### group by haplogroup
# get haplotype
h1 <- haplotype(DF1)
h1 <- sort(h1, what = "labels")
net1 <- haploNet(h1)
# for printing haplo pie chart
ind.hap1<-with(
    stack(setNames(attr(h1, "index"), rownames(h1))),
    table(hap=ind, pop=rownames(DF1)[values])
)

### group by sample name
DF2<-DF
h2 <- haplotype(DF2)
h2 <- sort(h2, what = "labels")
# for printing haplo pie chart
ind.hap2<-with(
    stack(setNames(attr(h2, "index"), rownames(h2))),
    table(hap=ind, pop=rownames(DF2)[values])
)

### get list of members of hap network
# ex. want haplogroup I and all members
HAPNUM="I"
ind.hap2[rownames(ind.hap2)==HAPNUM,][ind.hap2[rownames(ind.hap2)==HAPNUM,]==1]

### get all haplogroup and their assigned members
# the ind.hap should be sample name 
OUT<- data.frame(NETWORK=character(),NAME=character(),GROUP=character())
for (H in rownames(ind.hap2)){H_LIST<-ind.hap2[rownames(ind.hap2)==H,][ind.hap2[rownames(ind.hap2)==H,]==1]; OUT<-rbind(OUT,cbind(rep(H,length(H_LIST)),LIST[as.character(LIST$V1)%in%names(H_LIST),]))}

### plot halpo network
plot(net1, size=attr(net1, "freq"), scale.ratio = 7, cex = 0.8, pie=ind.hap1,threshold=0,bg=color,labels=F,show.mutation=0)
