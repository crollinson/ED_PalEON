library(ggplot2)

paleon.status <- read.csv("Paleon_MIP_Phase2_ED_Order_Status.csv", na.strings="")
paleon.states <- map_data("state")

paleon.status$Status <- as.factor(ifelse(is.na(paleon.status$runs), "in queue", ifelse(substr(paleon.status$runs,1,1)=="*", "in progress", "completed")))
summary(paleon.status)

png("ED_Regional_Status.png", height=4, width=10, units="in", res=180)
ggplot() +
	geom_raster(data=paleon.status, aes(x=lon, y=lat, fill=Status)) +
	geom_path(data=paleon.states, aes(x=long, y=lat, group=group), size=0.25) +
	# geom_point(aes(x=lon, y=lat), size=1, color="blue") +
    scale_x_continuous(limits=range(paleon.status$lon), expand=c(0,0), name="Longitude (degrees)") +
    scale_y_continuous(limits=range(paleon.status$lat), expand=c(0,0), name="Latitude (degrees)") +
    scale_fill_manual(values=c("red", "blue", "gray50")) +
	coord_equal(ratio=1) +
	theme_bw()
dev.off()