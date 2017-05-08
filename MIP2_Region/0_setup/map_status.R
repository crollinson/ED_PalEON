library(ggplot2)

paleon.origin <- read.csv("Paleon_MIP_Phase2_ED_Order.csv")
paleon.status <- read.csv("Paleon_MIP_Phase2_ED_Order_Status.csv", na.strings="")
paleon.states <- map_data("state")

paleon.status$Status <- as.factor(ifelse(is.na(paleon.status$location) | paleon.status$spininital=="ERROR", "in queue", ifelse(substr(paleon.status$runs,1,1)=="*" | is.na(paleon.status$runs), "in progress", "completed")))
summary(paleon.status)


paleon.origin2 <- merge(paleon.origin, paleon.status[,c("latlon", "Status")], all.x=T)
paleon.origin2$Status <- as.factor(ifelse(is.na(paleon.origin2$Status), "not run", paste(paleon.origin2$Status)))
summary(paleon.origin2)


if(length(unique(paleon.status$Status))==3){ 
  stat.color <- c("red", "blue", "gray50") 
} else{ 
  stat.color<-c("red", "gray50")
}



png("ED_Regional_Status.png", height=4, width=10, units="in", res=180)
ggplot() +
	geom_raster(data=paleon.origin2, aes(x=lon, y=lat), fill="gray80") +
  geom_raster(data=paleon.origin2, aes(x=lon, y=lat, fill=Status)) +
	geom_path(data=paleon.states, aes(x=long, y=lat, group=group), size=0.25) +
	# geom_point(aes(x=lon, y=lat), size=1, color="blue") +
    scale_x_continuous(limits=range(paleon.status$lon), expand=c(0,0), name="Longitude (degrees)") +
    scale_y_continuous(limits=range(paleon.status$lat), expand=c(0,0), name="Latitude (degrees)") +
    scale_fill_manual(values=c("gray30", "blue", "red", "gray95")) +
	coord_equal(ratio=1) +
	theme_bw()
dev.off()

# png("ED_Regional_FillOrder.png", height=4, width=10, units="in", res=180)
# ggplot() +
	# geom_raster(data=paleon.status, aes(x=lon, y=lat, fill=num)) +
	# geom_path(data=paleon.states, aes(x=long, y=lat, group=group), size=0.25) +
	# # geom_point(aes(x=lon, y=lat), size=1, color="blue") +
    # scale_x_continuous(limits=range(paleon.status$lon), expand=c(0,0), name="Longitude (degrees)") +
    # scale_y_continuous(limits=range(paleon.status$lat), expand=c(0,0), name="Latitude (degrees)") +
    # # scale_fill_manual(values=stat.color) +
	# coord_equal(ratio=1) +
	# theme_bw()
# dev.off()