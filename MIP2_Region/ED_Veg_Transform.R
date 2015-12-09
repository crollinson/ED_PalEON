#Process netCDF PalEON met files into HDF5 files for ED2:
#
#This works with files in the regional met driver rasters that can then be run site-by-site
#It loads the netCDF file, formats the data into HDF5 format, and renames variables and the date 
#to be in the ED2 HDF5 format with the correct dimensions.  
#
#It requires the rhdf5 library, which is not available on CRAN, but by can be installed locally:
#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")
#
#on GEO CLUSTER (local install of rhdf5): 
#install.packages("/usr4/spclpgm/jmatthes/zlibbioc_1.6.0.tar.gz",repos=NULL,type="source",lib="/usr4/spclpgm/jmatthes/")
#install.packages("/usr4/spclpgm/jmatthes/rhdf5_2.4.0.tar.gz",repos=NULL,type="source",lib="/usr4/spclpgm/jmatthes/")
#
#Original (Sites): Jaclyn Hatala Matthes, 1/7/14, jaclyn.hatala.matthes@gmail.com
#Edits (Sites): Christy Rollinson, January 2015, crollinson@gmail.com
#Edits (Region): Christy Rollinson, 2 December 2015, crollinson@gmail.com

library(ncdf4)
library(rhdf5)
library(abind)

in.path  <- "/projectnb/dietzelab/EDI/oge2OLD/OGE2_30S030W.h5"
out.path <- "/projectnb/dietzelab/paleon/ED_runs/phase2_env_drivers/"
dir.create(file.path(out.path), showWarnings = FALSE)


veg <- nc_open(in.path)
oge <- ncvar_get(veg, "oge2")
nc_close(veg)

oge[,] <- min(oge)


plot(oge)

file.out <- file.path(out.path, "VEG_MASK_30S030W.h5")
h5createFile(file.out)
h5write(oge, file.out,"oge2")

