## --------------------------------------------------------------
## Reformatting of HDF5 ED2 output to PalEON standardized ncdf
## Loosely based on the PEcAn script (model2netcdf.ED2)
## --------------------------------------------------------------

## --------------------------------------------------------------
## Necessary Libraries
## --------------------------------------------------------------
library(ncdf4)
library(zoo)
#library(bigmemory)
# library(abind)



getHdf5Data <- function(nc, var) {
	if(var %in% names(nc$var)) {
		return(ncvar_get(nc, var))
	} else {
		print("Could not find", var, "in ed hdf5 output.")
		return(-999)
    	}
  	}

add <- function(dat, col) {
	### CR Note: This has been modified from the PEcAn code and will only work work with adding vectors (no 3-D array adding)
	if(length(out) < col){
		out[[col]] <- array(dat)
	} else {
		out[[col]] <- cbind(out[[col]], array(dat))
	}
	return(out)
}

yr2sec <- 1/(365*24*60*60)
mo2sec <- 1/(12*24*60*60)

## ------------------------------------------------------------------------------
## Extracting ED data outside of the function/loop created by PEcAn folks
## Function Name: mdoel2netcdf.ED2
## ------------------------------------------------------------------------------

## ------------------------------------ 
# Step 1: Creating a list of all files meeting the criteria
  flist <- dir("analy/","-E-") # edited by CRR
  if (length(flist) == 0) {
    print(paste("*** WARNING: No output for :",raw.dir)) # Edited by CRR
    break
  }

  index <- gregexpr("-E-",flist[1])[[1]] # Searching for the monthly data marker (-E-);  
  index <- index[1] # indexing off of just where the monthly flag starts

## ------------------------------------ 
# Creating a blank matrix & then adding in the variables that are static through time (soil, PFT info)

  for(i in 1:length(flist)){ # looping through each of the files of interest
#	print(paste0("-------------------  Year: ", start, " - ", end, "  ----------")) 
    yr <- as.numeric(substr(flist[i],index+3,index+6)) # putting in the Years
    mo <- as.numeric(substr(flist[i],index+8,index+9)) 
    print(paste0("processing ", yr, " - ", mo))
    
    ncT <- nc_open(file.path("analy/", flist[i])) # Opening the hdf5 file for the month of interest (package ndcf4 will read hdf5)


    ## ----------------
	  ## Energy Fluxes
	  ## ----------------
      # Rnet - net radiation
      rnet <- ncvar_get(ncT, "MMEAN_RNET_PY")
    
      # LW_albedo - Longwave Albedo
  		albedo.lw <- ncvar_get(ncT, "MMEAN_RLONG_ALBEDO_PY")

	  	# SW_albedo - Shortwave Albedo -- NOT FOUND
	  	albedo.sw <- ncvar_get(ncT, "MMEAN_ALBEDO_PY")
	  	
	  	# LWdown - Net Longwave Radiation
	  	lwdown <- ncvar_get(ncT, "MMEAN_ATM_RLONG_PY") # Units: W/m2

	  	# swdown - Net Shortwave Radiation (incoming - upgoing)
      swdown <- ncvar_get(ncT, "MMEAN_ATM_RSHORT_PY") # Units: W/m2

      # LWnet - Net Longwave Radiation
      lwup <- ncvar_get(ncT, "MMEAN_RLONGUP_PY") # Units: W/m2
    
      # swnet - Net Shortwave Radiation (incoming - upgoing)
      swup <- ncvar_get(ncT, "MMEAN_RSHORTUP_PY") # Units: W/m2
    
      # Qh - Sensible Heat -  ATM -> CAS
	  	qh <- ncvar_get(ncT, "MMEAN_SENSIBLE_AC_PY")*-1 # Units: W/m2
	  	
	  	# Qle - Latent Heat = Evapotranspiration
      qle <- ncvar_get(ncT, "MMEAN_VAPOR_AC_PY")*(-2.26e6) # units: kg/m2/s
        
      # Qg - top layer ground sensible heat
      qg.all <- ncvar_get(ncT, "MMEAN_SENSIBLE_GG_PY")
      qg <- qg.all[length(qg.all)] # units: kg/m2/s

  
      # Snow Depth
    	snow <- ncvar_get(ncT, "MMEAN_SFCW_DEPTH_PY") # units: m

    data.temp <- data.frame(yr, mo, rnet, albedo.lw, albedo.sw, lwdown, swdown, lwup, swup, qh, qle, qg, snow)

		if(i==1){
			energy.out <- data.temp
		} else {
			energy.out <- rbind(energy.out, data.temp)
		}

	}
	
write.csv(energy.out, "Energy_Check.csv", row.names=F)