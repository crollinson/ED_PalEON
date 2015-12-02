#Process netCDF PalEON met files into HDF5 files for ED2:
#
#This works with files in the format site_metvar_year_month.nc (i.e. Ha1_lwdown_1850_01.nc)
#It loads the netCDF file, formats the data into HDF5 format, and renames variables and the date 
#to be in the ED2 HDF5 format with the correct dimensions.  
#
#It requires the rhdf5 library, which is not available on CRAN, but by can be installed locally:
#source("http://bioconductor.org/biocLite.R")
#a
#
#on GEO CLUSTER (local install of rhdf5): 
#install.packages("/usr4/spclpgm/jmatthes/zlibbioc_1.6.0.tar.gz",repos=NULL,type="source",lib="/usr4/spclpgm/jmatthes/")
#install.packages("/usr4/spclpgm/jmatthes/rhdf5_2.4.0.tar.gz",repos=NULL,type="source",lib="/usr4/spclpgm/jmatthes/")
#
#Original: Jaclyn Hatala Matthes, 1/7/14, jaclyn.hatala.matthes@gmail.com
#Edits: Christy Rollinson, January 2015, crollinson@gmail.com

library(ncdf4)
library(rhdf5)
library(abind)

in.path  <- "/projectnb/dietzelab/paleon/met_regional/phase2_met_regional_v2"
out.path <- "/projectnb/dietzelab/paleon/ED_runs/met_drivers/phase2_met"
dir.create(file.path(out.path), showWarnings = FALSE)

# sites <- c("PHA",   "PHO",  "PUN",  "PBL",  "PDL",  "PMB")
# lat   <- c(42.54,   45.25,  46.22,  46.28,  47.17,  43.61)
# lon   <- c(-72.18, -68.73, -89.53, -94.58, -95.17, -82.83)
orig.vars <- c("lwdown", "precipf", "psurf", "qair", "swdown", "tair", "wind")
ed2.vars  <- c( "dlwrf",   "prate",  "pres",   "sh",  "vbdsf",  "tmp", "ugrd")
month.txt <- c("JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC")



  for(v in 1:length(orig.vars)){
    print(orig.vars[v])    
    var.path <- file.path(in.path,orig.vars[v])
    in.files <- list.files(var.path)
    dir.create(file.path(out.path,ed2.vars[v]), showWarnings = FALSE)

    for(f in 1:length(in.files)){
      
      #open and read netcdf file
      nc.file <- nc_open(file.path(var.path,in.files[f]))
      var     <- ncvar_get(nc.file,orig.vars[v])
      time    <- ncvar_get(nc.file,"time")
      lat     <- ncvar_get(nc.file,"lat")
      lon     <- ncvar_get(nc.file,"lon")
      nc_close(nc.file)
      
      # var <- array(var,dim=dim(var))                   
      
      #process year and month for naming
      filesplit <- strsplit(in.files[f],"_")
      year  <- as.numeric(filesplit[[1]][2])+1000 ###CAREFUL - I HAD TO ADD 1000 FOR PALEON
      monthsplit <- strsplit(filesplit[[1]][3],".nc")
      month <- monthsplit[[1]]
      month.num <- as.numeric(month)
      
      #write HDF5 file
      out.file <- paste(out.path,"/",ed2.vars[v],"/",ed2.vars[v],"_",year,month.txt[month.num],".h5",sep="")
      h5createFile(out.file)
      h5write(var,out.file,ed2.vars[v])
      h5write(time,out.file,"time")
      h5write(lon,out.file,"lon")
      h5write(lat,out.file,"lat")
      # H5Fclose(out.file) # don't need this because of how we created & wrote the files
    }
  }


# Tacking on CO2 -- copying onto a blank tair
co2.file <- "/projectnb/dietzelab/paleon/env_regional/phase2_env_drivers_v2/co2/paleon_monthly_co2.nc"
co2.in <- nc_open(co2.file)
co2.mo <- ncvar_get(co2.in, "co2")
nc_close(co2.in)


    print("CO2")    
    dir.create(file.path(out.path,"co2"), showWarnings = FALSE)
    var.path <- file.path(in.path,"tair")
    in.files <- list.files(var.path)

    for(f in 1:length(in.files)){
      
      #open and read netcdf file
      nc.file <- nc_open(file.path(var.path,in.files[f]))
      var     <- ncvar_get(nc.file,"tair")
      time    <- ncvar_get(nc.file,"time")
      lat     <- ncvar_get(nc.file,"lat")
      lon     <- ncvar_get(nc.file,"lon")
      nc_close(nc.file)
      
      # Overwriting the tair data with co2 in ALL cells
      # i.e. constant co2 across space and time for that month
      var[,,] <- co2.mo[f]
      
      #process year and month for naming
      filesplit <- strsplit(in.files[f],"_")
      year  <- as.numeric(filesplit[[1]][2])+1000 ###CAREFUL - I HAD TO ADD 1000 FOR PALEON
      monthsplit <- strsplit(filesplit[[1]][3],".nc")
      month <- monthsplit[[1]]
      month.num <- as.numeric(month)
      
      #write HDF5 file
      out.file <- paste(out.path,"/","co2","/","co2","_",year,month.txt[month.num],".h5",sep="")
      h5createFile(out.file)
      h5write(var,out.file,"co2")
      h5write(time,out.file,"time")
      h5write(lon,out.file,"lon")
      h5write(lat,out.file,"lat")
      # H5Fclose(out.file) # don't need this because of how we created & wrote the files
    }

