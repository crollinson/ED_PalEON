# ED_PalEON: Scripts to Execute PalEON MIP ED Runs
Christy Rollinson (crollinson@gmail.com)
10 March, 2016


This folder contains all of the scripts necessary to execute the PalEON MIP Phase 2 
regional runs on a cell-by-cell basis.  For this to work properly, there are several 
steps necessary to format files, perform the spinup (3 stages), and complete the runs.
Details about each of the steps is now located in the wiki (part of this Github 
repository).  

The master branch of this repository is configured for Boston University's *geo* 
computing cluster. Please create a new branch for new computing locations. A list of
required programs & libraries for running ED and the PalEON-specific helper scripts are
below.

Note: This repository also has the base scripts for the site-level runs, but many of the 
      file paths will not line up since this repository was made with the intention of
      helping distribute the effort for the regional runs

--------------------------

#### Running ED will require the following programs & libraries installed and active:
1. hdf5 (v1.6.10 or greater)
2. fortran openmpi compiler
2. nco
3. R
   - packages: ncdf4, zoo, raster, ggplot2, abind, rhdf5, chron, colorspace
   - rhdf5 will need to be installed from Bioconductor: http://bioconductor.org/packages/release/bioc/html/rhdf5.html


