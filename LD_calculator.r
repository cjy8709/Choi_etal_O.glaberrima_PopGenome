library("ggplot2"); library("data.table")

args <- commandArgs(trailingOnly = TRUE)

LD<-fread(args[1],header=T)

#ggplot(LD, aes(x = BP_B - BP_A, y = R2))+geom_point()

LD$distancekb <- with (LD, LD$BP_B-LD$BP_A)/(as.numeric(args[4])*1000/as.numeric(args[3]))

LD$grp <- cut(LD$distancekb, 0:as.numeric(args[3]))

r2means <- with (LD, tapply(LD$R2, LD$grp, FUN = mean))

outname=paste0("r2mean_CHR", args[2],"_",args[3],"bin", ".txt")
write.table(r2means,outname,quote=F,col.names=F)

outname=paste0("LD_avg_CHR", args[2],"_",args[3],"bin", ".tiff")
tiff(outname,height = 10*600, width = 10*600, units = 'px', res=600, compression = "lzw")
plot(r2means)
dev.off()
