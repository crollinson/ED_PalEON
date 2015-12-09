# For Sites crashing, extract met to see what's going on

library(ncdf4)

dir.out  <- "/projectnb/dietzelab/paleon/ED_runs/met_drivers/phase2_met_qaqc" 
dir.met  <- "/projectnb/dietzelab/paleon/ED_runs/met_drivers/phase2_met" 
vars.met <- dir(dir.met)


# First crash: PHO cell
lat=45.25
lon=-68.75



for(SITE in 1:length(lat)){
	dat.mean <- data.frame(array(dim=c(0,length(vars.met)))); names(dat.mean) <- vars.met
	dat.min  <- data.frame(array(dim=c(0,length(vars.met)))); names(dat.min) <- vars.met
	dat.max  <- data.frame(array(dim=c(0,length(vars.met)))); names(dat.max) <- vars.met
	for(v in vars.met){
		print(paste0(v))
		file.var <- dir(file.path(dir.met, v))
		for(i in 1:length(file.var)){
			file.now <- nc_open(file.path(dir.met, v, file.var[i]))
			dat.temp <- ncvar_get(file.now, v)
			lat.nc   <- ncvar_get(file.now, "lat")
			lon.nc   <- ncvar_get(file.now, "lon")
			nc_close(file.now)
			
			dat.cell <- dat.temp[,which(lon.nc==lon[SITE]),which(lat.nc==lat[SITE])]
			
			dat.mean[i,v] <- mean(dat.cell)
			dat.min [i,v] <- min (dat.cell)
			dat.max [i,v] <- max (dat.cell)
		}
	}
	write.csv(dat.mean, file=file.path(dir.out, paste0("lat", lat[SITE], "lon", lon[SITE], "_Met_Month_mean.csv")), row.names=T)
	write.csv(dat.min , file=file.path(dir.out, paste0("lat", lat[SITE], "lon", lon[SITE], "_Met_Month_min.csv" )), row.names=T)
	write.csv(dat.max , file=file.path(dir.out, paste0("lat", lat[SITE], "lon", lon[SITE], "_Met_Month_max.csv" )), row.names=T)
}
