### plotting admixture result by hiearchically clustering and plot

library(RColorBrewer); library(cba)

admix<-read.table("ngsAdmix/K2.txt",as.is=T)

# cluster admix proportions
Madmix<-t(as.matrix(admix[,-ncol(admix)]))
d=dist(as.matrix(admix[,-ncol(admix)]))
hc=hclust(d)

#Optimal Leaf Ordering Of Binary Trees
co <- order.optimal(d, hc$merge); ho <- hc; ho$merge <- co$merge; ho$order <- co$order
Madmix<-Madmix[,ho$order];

## plotting
pop<-read.table("ngsAdmix/pop.list",header=T,as.is=T)

h<-barplot(Madmix,col=brewer.pal(9,"Set1")[1:nrow(Madmix)],space=0,border=NA,xlab="",ylab="admixture",ylim=c(-0.15,1.24))
# glaberrima grouping
text(h, -0.05, ifelse(as.integer(as.factor(pop$Species[ho$order]))==1," ","*"),cex=1.1)
# plot star for the Obar grouping by Wang et al.
text(h, 1.05, ifelse(pop$Accessionname[ho$order]%in%pop$Accessionname[pop$Wangetal_Group=="OB_I"],"*"," "),cex=1.1,col="blue")
text(h, 1.09, ifelse(pop$Accessionname[ho$order]%in%pop$Accessionname[pop$Wangetal_Group=="OB_II"],"*"," "),cex=1.1,col="#A65628")
text(h, 1.13, ifelse(pop$Accessionname[ho$order]%in%pop$Accessionname[pop$Wangetal_Group=="OB_III"],"*"," "),cex=1.1,col="red")
text(h, 1.17, ifelse(pop$Accessionname[ho$order]%in%pop$Accessionname[pop$Wangetal_Group=="OB_IV"],"*"," "),cex=1.1,col="gold2")
text(h, 1.21, ifelse(pop$Accessionname[ho$order]%in%pop$Accessionname[pop$Wangetal_Group=="OB_V"],"*"," "),cex=1.1,col="#F781BF")



