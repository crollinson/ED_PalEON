# Converting the PalEON Soil Depth driver to a table for ED

# Header: Resolution
# Skip 2 lines

# Row.names = latitude
# column names = Longitude
# Cell values = depths

library(ncdf4)
soil.in <- nc_open("~/Dropbox/PalEON_CR/env_regional/env_paleon/soil/paleon_soil_soil_depth.nc")
summary(soil.in$var)
soil.depth <- t(ncvar_get(soil.in, "soil_depth"))
soil.depth <- round(soil.depth, 2)
soil.depth[is.na(soil.depth)] <- 0
lat <- ncvar_get(soil.in, "latitude")
lon <- ncvar_get(soil.in, "longitude")
# colnames(soil.depth) <- as.numeric(lon)
# rownames(soil.depth) <- as.numeric(lat)
summary(soil.depth)
head(soil.depth)

# write.table(formatC(soil.depth, format="f", digits=2), file="~/Dropbox/PalEON_CR/ED_PalEON/MIP2_Region/soil_depths.dat", sep="      ", row.names=as.numeric(lat), col.names=as.numeric(lon))

# write.table(formatC(soil.depth, format="f", digits=2), file="~/Dropbox/PalEON_CR/ED_PalEON/MIP2_Region/soil_depths.dat", sep="     ", row.names=as.numeric(lat), col.names=as.numeric(lon))

write.table(formatC(soil.depth,format="f", digits=2, width=10), file="soil_depths.dat", sep="", col.names=paste0("    ",lon), row.names=paste0("    ",lat))