# Checking Out the met for a few specific sites that are bonking
library(raster)
library(ncdf4)
library(ggplot2)

# Temp
tmp.path  <- "phase2_met/tmp"
tmp.files <- dir(tmp.path)
tmp <- stack(file.path(tmp.path, tmp.files[1]))
tmp


plot(tmp)


tmp.nc <- nc_open(file.path(tmp.path, tmp.files[1]))
summary(tmp.nc$var)
tmp.lat <- ncvar_get(tmp.nc, "lat")
tmp.lon <- ncvar_get(tmp.nc, "lon")
tmp.df <- ncvar_get(tmp.nc, "tmp")
dim(tmp.df)

tmp.df <- data.frame(tmp.df[1,,])
row.names(tmp.df) <- tmp.lon
names(tmp.df) <- tmp.lat
summary(tmp.df)

tmp.stack <- stack(tmp.df)
names(tmp.stack) <- c("tmp", "lat")
tmp.stack$lon <- tmp.lon
tmp.stack[tmp.stack$tmp==0, "tmp"] <- NA
tmp.stack$lat <- as.numeric(paste(tmp.stack$lat))
summary(tmp.stack)

points.bad <- data.frame(lon = c(-82.75, -84.75),
						 lat = c( 43.75,  45.25),
						 name = c("PDL", "36"))

points.sp <- SpatialPointsDataFrame(coords=points.bad[,c("lon", "lat")], data=points.bad)
plot(points.sp)

plot(tmp)
plot(points.sp, add=T, pch=9)

ggplot(data=tmp.stack) +
	geom_raster(aes(x=lon, y=lat, fill=tmp)) +
	geom_point(data=points.bad, aes(x=lon, y=lat), size=1, color="red") +
	coord_equal(ratio=1)





precip.path  <- "phase2_met/prate"
precip.files <- dir(precip.path)
precip <- stack(file.path(precip.path, precip.files[1]))
precip
plot(precip$prate_1850APR.1)
