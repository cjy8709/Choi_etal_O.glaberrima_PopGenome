# R commands used to plot West Africa geography, and related data

library(dplyr); library(RColorBrewer); library(ggplot2); library(mapdata); library(maptools); library(scatterpie); library(patchwork)

#### plot West Africa geography
# data used for drawing rivers. Can be downloaded online https://www.naturalearthdata.com/downloads/
shapeData <- readShapeLines("~/ne_50m_rivers_lake_centerlines/ne_50m_rivers_lake_centerlines.shp",delete_null_obj=TRUE)

# convert input shapefile to a R dataframe
shapeData@data$id <- rownames(shapeData@data)
watershedPoints <- fortify(shapeData, region = "id")
watershedDF <- merge(watershedPoints, shapeData@data, by = "id")

# subset the data to include the rivers from West Africa of interest
watershedDF_Niger <- filter(watershedDF, name %in% c("Niger"))
watershedDF_Benue <- filter(watershedDF, name %in% c("Benue"))
watershedDF_Volta <- filter(watershedDF, name %in% c("Volta"))
watershedDF_Senegal <- filter(watershedDF, name %in% c("Sénégal"))

# plot the countries from West Africa of interest
WAmap<-ggplot() + geom_polygon(data = map_data("worldHires", "Guinea"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Mali"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Burkina"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Ivory"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Sierra"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Liberia"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Benin"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Togo"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Ghana"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Niger"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Nigeria"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Chad"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Cameroon"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Senegal"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Mauritania"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Algeria"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Central African"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Congo"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Zaire"), aes(x=long, y = lat, group = group), fill = "white", color="black") +
geom_polygon(data = map_data("worldHires", "Gambia"), aes(x=long, y = lat, group = group), fill = "white", color="black")

# Plot the rivers
WAmap <- WAmap + geom_path(data=watershedDF_Niger, aes(x = long, y = lat, group = group), color = 'blue', size=0.5)
WAmap <- WAmap + geom_path(data=watershedDF_Benue, aes(x = long, y = lat, group = group), color = 'blue', size=0.5)
WAmap <- WAmap + geom_path(data=watershedDF_Volta, aes(x = long, y = lat, group = group), color = 'blue', size=0.5)
WAmap <- WAmap + geom_path(data=watershedDF_Senegal, aes(x = long, y = lat, group = group), color = 'blue', size=0.5)
WAmapRegion <- WAmap + coord_fixed(xlim = c(-19, 20),  ylim = c(4.5, 18), ratio = 1.2)+theme(line = element_blank(), panel.background = element_rect(fill = "lightsteelblue1"),legend.position="none")


#### plot sample distribution. Data used from S1 Table of Choi et al.
pop<-read.table("~/S1_Table.txt",h=T)

# plot sample distriubtion in West Africa that was sequenced by Choi et al. study
WAmapRegion+geom_point(data=pop[pop$SequencedBy=="Current_study",],aes(Longitude,Latitude,color="red"),alpha=0.85,size=2)

# plot sample distribution of barthii sample that was sequenced by Choi et al. study
WAmapRegion+geom_point(data=pop[pop$Species=="O.barthii" & pop$SequencedBy=="Current_study",],aes(Longitude,Latitude,color="red"),alpha=0.85,size=2)


#### plot admixture results onto West Africa
# load pop info
pop<-read.table("ngsAdmix/pop.list",h=T,comment.char="")

# load admix result
admix<-read.table("ngsAdmix/K7.txt")

# pie chart plot the admixture K group and plot it on geography 
WAmapRegion <- WAmap + coord_fixed(xlim = c(-19, 20),  ylim = c(4.5, 18), ratio = 1.2)
for (i in which(pop$Species=="O.glaberrima")){
data=cbind(pop[i,][,3],pop[i,][,4],admix[i,1:ncol(admix)-1]); colnames(data)=c("lat","lon",LETTERS[1:(ncol(data)-2)])
WAmapRegion=WAmapRegion+geom_scatterpie(aes(x=lon,y=lat,r=0.3),data=data,cols=LETTERS[1:(ncol(data)-2)],color=NA,alpha=0.75)
}
WAmapRegion<-WAmapRegion+scale_fill_manual(values=brewer.pal(9,"Set1")[1:length(LETTERS[1:(ncol(data)-2)])])
WAmapRegion+theme(line = element_blank(), panel.background = element_rect(fill = "lightsteelblue1"),legend.position="none")

