library(ggplot2)

r<-read.table("r2mean_1000bin.txt",header=T)

ggplot(r,aes(x=kbp_bin,y=avgLD,color=group))+ stat_smooth(method = "loess", se = FALSE,formula = y ~ x, size = 3)+ scale_x_continuous(breaks = seq(0, 1000, 200))+theme_bw()+scale_color_manual(values=c("#F781BF","#FFFF33","#984EA3","#377EB8","#FF7F00","#4DAF4A","#A65628"))
