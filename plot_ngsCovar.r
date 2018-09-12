# plot PCA results
library(ggplot2)

# PCA file
covar <- read.table("ngsCovar/glaberrima.PCA.covar.txt", stringsAsFact=F);
# popl info file
pop <- read.table("ngsCovar/pop.txt", comment.char = "")

# Eigenvalues
eig <- eigen(covar, symm=TRUE);
eig$val <- eig$val/sum(eig$val);

# prepare for plotting
PC <- as.data.frame(eig$vectors)
colnames(PC) <- gsub("V", "PC", colnames(PC))
PC$col<-factor(pop[,2])

# plot
ggplot() + geom_point(data=PC, aes_string(x="PC1", y="PC2",color="col"))+scale_colour_identity()+theme_bw()
