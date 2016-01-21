# --------------------------------------------------------------------------
# This scripts organizes the extracted output from ED runs (in this case 
# the initial spin) and does some graphical and quantitative sanity checks
#
# Christy Rollinson (crollinson@gmail.com)
# January 2016
#
# Workflow Summary
# 1. Load Libraries, set up directories, constants, etc
#    A. Identify Location of the output we're looking at
#    B. Identify Sites of Interest
#    C. Map those sites spatially (can be skipped)
#    D. Define some useful constants
# 2. Extract data from blocked .nc files and bind all sites together
# 3. Actual QA/QC Graphs & Numbers On Key Variables
#    A. Composition/Biomass 
#    B. Leaf Area Index (LAI)
#    C. Gross Primary Productivity (GPP)
#    D. Autotrophic Respiration (Ra)
#    E. Heterotrophic Respiration (Rh)
#    F. Soil Moisture 
#    G. Fire
# --------------------------------------------------------------------------

# ----------------------------------------
# 1. Load Libraries, set up directories, constants, etc
# ----------------------------------------
library(ncdf4); library(raster)
library(abind)
library(ggplot2); library(grid)

# -----------------------
# A. Location of the files we want to look at
# -----------------------
ed.out <- "~/Dropbox/PalEON_CR/ED_PalEON/MIP2_Region/3_spin_finish/spinfinish_qaqc.v1"
# -----------------------

# -----------------------
# B. List of sites we want to qaqc
# -----------------------
sites <- data.frame(site=c("lat46.25lon-89.75", "lat46.25lon-94.75", "lat45.25lon-68.75", "lat42.75lon-72.25"))
sites$lat <- as.numeric(substr(sites$site, 4,8))
sites$lon <- as.numeric(substr(sites$site, 12,17))
summary(sites)
# -----------------------

# # -----------------------
# # C. Map the qaqc sites (can be skipped)
# # -----------------------
# # Paleon Mask (to graph the qaqc locations)
# paleon.domain <- data.frame(rasterToPoints(raster("~/Desktop/Research/PalEON_CR/env_regional/env_paleon/domain_mask/paleon_domain.nc")))
# summary(paleon.domain)

# ggplot() + 
	# geom_raster(data=paleon.domain, aes(x=x, y=y), fill="gray50") +
	# geom_point(data=sites, aes(x=lon, y=lat), size=8, color="red2") +
	# coord_equal(ratio=1) +
	# theme_bw()
# # -----------------------
	
# -----------------------
# D. Get some useful info about the output
# -----------------------
# Getting the variables names
ncMT <- nc_open(file.path(ed.out,sites[1,"site"], dir(file.path(ed.out, sites[1,"site"]), ".nc")[1]))
ed.var <- names(ncMT$var)
nc_close(ncMT)

# Some other useful constants
yr.start  <- 850 # First year of output
yr.end    <- 1850 # Last year of output
yr.blocks <- 100 # Number years in each output (just to avoid hard-coding some places)
nsoil.max <- 12 # Max number of soil layers based on ED2IN_SpinInitBase
npft      <- 17 # total number of ED PFTs
var.diversity <- c("PFT", "Fcomp", "BA", "Dens", "Mort")
soil.var <- c("SoilDepth", "SoilMoist", "SoilTemp")

sec2yr <- 1/(365*24*60*60)
sec2mo <- 1/(12*24*60*60)
# -----------------------
# ----------------------------------------

# ----------------------------------------
# 2. Extract information
# ----------------------------------------
ed <- list()
for(s in 1:nrow(sites)){
  print(paste0(" =========== ", sites[s,"site"], " =========== "))
  dir.ed <- file.path(ed.out, sites[s,"site"])
  files.ed <- dir(dir.ed, ".nc")
  
  ed.var.list <- list()
  
  # -----------------------
  # File loop extracting time series by variable group
  # -----------------------
  for(i in 1:length(files.ed)){ # Loop through each file
    ncMT <- nc_open(file.path(dir.ed, files.ed[i]))

    for(v in ed.var[!(ed.var %in% c("SoilDepth", "PFT"))]){ # Now go through each variable in that file
      if(i == 1){ # If this is the first file, lets set some things up
      	# Save the soil depths only at the first time step because it doesn't change
      	# Note, we need
      	nzt <- length(ncvar_get(ncMT, "AGB")) # The number of time steps in this file
      	depth.temp <- ncvar_get(ncMT, "SoilDepth") # Soil depth for this site
      	nzg <- length(depth.temp) # Number of soil layers
      	
      	ed.var.list[["SoilDepth"]] <- c(rep(NA, nsoil.max-nzg), depth.temp)

      	ed.var.list[["PFT"]] <- ncvar_get(ncMT, "PFT")

		# Set up the temporary array where things get to go
		# Soil & PFT variables need some more specific dimensions to make sure things don't pop in & out
		#   -- using the maximum potential number of months in a file as a dummy time variable
      	if(v %in% soil.var[!(soil.var=="SoilDepth")]){ 
      		temp <- cbind(array(dim=c(nzt,(nsoil.max-nzg))), t(ncvar_get(ncMT, v)))
      	} else if(v %in% var.diversity[!(var.diversity=="PFT")]){ 
      		temp <- t(ncvar_get(ncMT, v))
      	} else {
      		temp <- ncvar_get(ncMT, v)
      	}
      } else {	
      	nzt <- length(ncvar_get(ncMT, "AGB")) # The number of time steps in this file

      	temp <- ed.var.list[[v]]

      	if(v %in% soil.var[!(soil.var=="SoilDepth")]){ 
    		temp <- rbind(temp, cbind(array(dim=c(nzt,(nsoil.max-nzg))), t(ncvar_get(ncMT, v))))
      	} else if(v %in% var.diversity[!(var.diversity=="PFT")]){ 
			temp <- rbind(temp, t(ncvar_get(ncMT, v)))
	    } else {      
			temp <- c(temp, ncvar_get(ncMT, v)) 
	  	}
	  } 

      ed.var.list[[v]] <- temp
    } # End Variable loop
    nc_close(ncMT)      
  } # End file loop
  # -----------------------

  # -----------------------
  # Adding variable groups to master model list
  # -----------------------
  for(v in ed.var){
    if(s == 1){
    	if(v %in% c(soil.var[!(soil.var=="SoilDepth")], var.diversity[!(var.diversity=="PFT")])){
			ed[[v]] <- array(ed.var.list[[v]], dim=c(dim(ed.var.list[[v]]),1))
    	} else {
    		ed[[v]] <- array(ed.var.list[[v]], dim=c(length(ed.var.list[[v]]),1))
    	}
    } else {
    	if(v %in% c(soil.var[!(soil.var=="SoilDepth")], var.diversity[!(var.diversity=="PFT")])){
    	  ed[[v]] <- abind(ed[[v]][1:min(nrow(ed[[v]]), nrow(ed.var.list[[v]])),,], ed.var.list[[v]][1:min(nrow(ed[[v]]), nrow(ed.var.list[[v]])),], along=3)
    	} else {
	      ed[[v]] <- cbind(ed[[v]][1:min(nrow(ed[[v]]), length(ed.var.list[[v]])),], ed.var.list[[v]][1:min(nrow(ed[[v]]), length(ed.var.list[[v]]))])
    	}
    }
	
  } 
  # -----------------------
} # End Site loop

# Assign site names:
# -- for 3-dimension arrays, this will be  the 3 dimension; for others it will be column names
for(v in ed.var){
	if(v %in% c(soil.var[!(soil.var=="SoilDepth")], var.diversity[!(var.diversity=="PFT")])){
		dimnames(ed[[v]])[[3]] <- sites$site
    } else { 
    	dimnames(ed[[v]])[[2]] <- sites$site
    }
}
# ----------------------------------------


# ----------------------------------------
# 3. Actual QA/QC Graphs & Numbers On Key Variables
#    A. Composition/Biomass 
#    B. Leaf Area Index (LAI)
#    C. Gross Primary Productivity (GPP)
#    D. Net Primary Productivity (NPP)
#    E. Autotrophic Respiration (Ra)
#    F. Heterotrophic Respiration (Rh)
#    G. Soil Moisture 
# ----------------------------------------
# -----------------------
# A. Composition/Biomass 
# -----------------------
summary(ed[["AGB"]])

pft.colors <- c("gray50", "green3", "darkgreen", "darkgoldenrod3", "darkorange3", "red3")
pfts.ed <- c("5-Grass", "6-North Pine", "8-Late Conifer", "9-Early Hardwood", "10-Mid Hardwood", "11-Late Hardwood")

# Plotting Biomass by PFT
pdf(file.path(ed.out, "AGB_byPFT.pdf"), height=11, width=8.5)
par(mfrow=c(ncol(ed$AGB)/2,ncol(ed$AGB)/2))
for(i in 1:ncol(ed$AGB)){
plot(ed$AGB[,i], type="l", col="black", lwd=2, ylim=c(0, max(ed$AGB, na.rm=T)))
	text(x=500, y=quantile(ed$AGB, 0.99, na.rm=T), dimnames(ed$AGB)[[2]][i], cex=1.5)
	lines(ed$AGB[,i]*ed$Fcomp[, 5,i], type="l", col=pft.colors[1], lwd=1.5)
	lines(ed$AGB[,i]*ed$Fcomp[, 6,i], type="l", col=pft.colors[2], lwd=1.5)
	lines(ed$AGB[,i]*ed$Fcomp[, 8,i], type="l", col=pft.colors[3], lwd=1.5)
	lines(ed$AGB[,i]*ed$Fcomp[, 9,i], type="l", col=pft.colors[4], lwd=1.5)
	lines(ed$AGB[,i]*ed$Fcomp[,10,i], type="l", col=pft.colors[5], lwd=1.5)
	lines(ed$AGB[,i]*ed$Fcomp[,11,i], type="l", col=pft.colors[6], lwd=1.5)
}
dev.off()
# -----------------------


# -----------------------
# B. LAI
# -----------------------
summary(ed$LAI)

pdf(file.path(ed.out, "LAI.pdf"), height=11, width=8.5)
par(mfrow=c(ncol(ed$LAI)/2,ncol(ed$LAI)/2))
for(i in 1:ncol(ed$LAI)){
plot(ed$LAI[,i], type="l", col="black", lwd=1, ylim=c(0, max(ed$LAI, na.rm=T)))
	text(x=10000, y=quantile(ed$LAI, 0.99, na.rm=T), dimnames(ed$LAI)[[2]][i], cex=1.5)
}
dev.off()
# -----------------------

# -----------------------
# C. GPP
# -----------------------
summary(ed$GPP/sec2yr)
head(ed$GPP)


pdf(file.path(ed.out, "GPP.pdf"), height=11, width=8.5)
par(mfrow=c(ncol(ed$GPP)/2,ncol(ed$GPP)/2))
for(i in 1:ncol(ed$GPP)){
plot(ed$GPP[,i]/sec2yr, type="l", col="black", lwd=1, ylim=range(ed$GPP, na.rm=T)/sec2yr)
	text(x=10000, y=quantile(ed$GPP, 0.999, na.rm=T)/sec2yr, dimnames(ed$GPP)[[2]][i], cex=1.5)
}
dev.off()
# -----------------------

# -----------------------
# D. NPP
# -----------------------
summary(ed$NPP/sec2yr)
summary(ed$NPP)

pdf(file.path(ed.out, "NPP.pdf"), height=11, width=8.5)
par(mfrow=c(ncol(ed$NPP)/2,ncol(ed$NPP)/2))
for(i in 1:ncol(ed$NPP)){
plot(ed$NPP[,i]/sec2yr, type="l", col="black", lwd=1, ylim=range(ed$NPP, na.rm=T)/sec2yr)
	text(x=10000, y=quantile(ed$NPP, 0.999, na.rm=T)/sec2yr, dimnames(ed$NPP)[[2]][i], cex=1.5)
}
dev.off()
# -----------------------

# -----------------------
# E. NEE
# -----------------------
summary(ed$NEE/sec2yr)
summary(ed$NEE)

pdf(file.path(ed.out, "NEE.pdf"), height=11, width=8.5)
par(mfrow=c(ncol(ed$NEE)/2,ncol(ed$NEE)/2))
for(i in 1:ncol(ed$NEE)){
plot(ed$NEE[,i]/sec2yr, type="l", col="black", lwd=1, ylim=range(ed$NEE, na.rm=T)/sec2yr)
	text(x=10000, y=quantile(ed$NEE, 0.999, na.rm=T)/sec2yr, dimnames(ed$NEE)[[2]][i], cex=1.5)
abline(h=0, col="red2")
}
dev.off()
# -----------------------


# -----------------------
# F. Ra
# -----------------------
summary(ed$AutoResp)

summary(ed$AutoResp/sec2yr)

pdf(file.path(ed.out, "AutoResp.pdf"), height=11, width=8.5)
par(mfrow=c(ncol(ed$AutoResp)/2,ncol(ed$AutoResp)/2))
for(i in 1:ncol(ed$AutoResp)){
plot(ed$AutoResp[,i]/sec2yr, type="l", col="black", lwd=1, ylim=range(ed$AutoResp, na.rm=T)/sec2yr)
	text(x=10000, y=quantile(ed$AutoResp, 0.999, na.rm=T)/sec2yr, dimnames(ed$AutoResp)[[2]][i], cex=1.5)
}
dev.off()
# -----------------------

# -----------------------
# G. Rh
# -----------------------
summary(ed$HeteroResp)

summary(ed$HeteroResp/sec2yr)

pdf(file.path(ed.out, "HeteroResp.pdf"), height=11, width=8.5)
par(mfrow=c(ncol(ed$HeteroResp)/2,ncol(ed$HeteroResp)/2))
for(i in 1:ncol(ed$HeteroResp)){
plot(ed$HeteroResp[,i]/sec2yr, type="l", col="black", lwd=1, ylim=range(ed$HeteroResp, na.rm=T)/sec2yr)
	text(x=10000, y=quantile(ed$HeteroResp, 0.999, na.rm=T)/sec2yr, dimnames(ed$HeteroResp)[[2]][i], cex=1.5)
}
dev.off()
# -----------------------


# -----------------------
# H. Soil Moist
# -----------------------
ed$SoilDepth
summary(ed$SoilMoist[,12,])
summary(ed$SoilMoist[,10,])
summary(ed$SoilMoist[,8,])
summary(ed$SoilMoist[,6,])

summary(ed$precipf*1e5+30)

pdf(file.path(ed.out, "SoilMoist.pdf"), height=11, width=8.5)
par(mfrow=c(ncol(ed$SoilDepth)/2,ncol(ed$SoilDepth)/2))
for(i in 1:ncol(ed$SoilDepth)){
plot(ed$SoilMoist[,12,i], type="l", col="blue", lwd=0.25, ylim=c(0, max(ed$SoilMoist, na.rm=T)+0.1))
	text(x=10000, y=max(ed$SoilMoist,na.rm=T)+0.05, dimnames(ed$SoilMoist)[[3]][i], cex=1.5)
	lines(ed$SoilMoist[,8,i], type="l", col="green", lwd=0.75)
	lines(ed$SoilMoist[,6,i], type="l", col="red", lwd=0.5)
	# lines(ed$SoilMoist[,5,i], type="l", col="black", lwd=0.5)
	# lines(ed$precipf[,i]*2e5+25, type="l", col="black", lwd=0.5)
	abline(h=mean(ed$precipf[,i])*2e5+25, col="red")
}
dev.off()
# -----------------------

# -----------------------
# I. Soil Temp
# -----------------------
ed$SoilDepth
summary(ed$tair)
summary(ed$SoilTemp[,12,])
summary(ed$SoilTemp[,10,])
summary(ed$SoilTemp[,8,])
summary(ed$SoilTemp[,6,])

pdf(file.path(ed.out, "SoilTemp.pdf"), height=11, width=8.5)
par(mfrow=c(ncol(ed$tair)/2,ncol(ed$tair)/2))
for(i in 1:ncol(ed$tair)){
plot(ed$tair[,i], type="l", col="black", lwd=0.33, ylim=range(ed$tair, na.rm=T))
	text(x=10000, y=quantile(ed$tair,0.999, na.rm=T), dimnames(ed$tair)[[2]][i], cex=1.5)
	lines(ed$SoilTemp[,12,i], type="l", col="blue", lwd=0.25)
	# lines(ed$SoilTemp[,8,i], type="l", col="green", lwd=0.75)
	# lines(ed$SoilTemp[,6,i], type="l", col="red", lwd=0.5)
}
dev.off()
# -----------------------

# -----------------------
# I. Soil Carbon
# -----------------------
# ed$TotSoilCarb
summary(ed$TotSoilCarb)

pdf(file.path(ed.out, "SoilCarb.pdf"), height=11, width=8.5)
par(mfrow=c(ncol(ed$TotSoilCarb)/2,ncol(ed$TotSoilCarb)/2))
for(i in 1:ncol(ed$TotSoilCarb)){
plot(ed$TotSoilCarb[,i], type="l", col="black", lwd=0.33, ylim=range(ed$TotSoilCarb, na.rm=T))
	text(x=10000, y=quantile(ed$TotSoilCarb,0.999, na.rm=T), dimnames(ed$TotSoilCarb)[[2]][i], cex=1.5)
}
dev.off()

# Looking at just the last 40 years (2 met cycles)
pdf(file.path(ed.out, "SoilCarb_Last40.pdf"), height=11, width=8.5)
par(mfrow=c(ncol(ed$TotSoilCarb)/2,ncol(ed$TotSoilCarb)/2))
for(i in 1:ncol(ed$TotSoilCarb)){
plot(ed$TotSoilCarb[(length(ed$TotSoilCarb[,i])-12*40):length(ed$TotSoilCarb[,i]),i], type="l", col="black", lwd=0.33, ylim=range(ed$TotSoilCarb[(length(ed$TotSoilCarb[,i])-12*40):length(ed$TotSoilCarb[,i]),], na.rm=T), ylab="TotSoilCarb (MgC/HA)")
	text(x=10000, y=quantile(ed$TotSoilCarb,0.999, na.rm=T), dimnames(ed$TotSoilCarb)[[2]][i], cex=1.5)
}
dev.off()
# -----------------------

# ----------------------------------------
