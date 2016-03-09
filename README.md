# ED_PalEON: Scripts to Execute PalEON MIP ED Runs
Christy Rollinson (crollinson@gmail.com)
7 January, 2016


This folder contains all of the scripts necessary to execute the PalEON MIP Phase 2 
regional runs on a cell-by-cell basis.  For this to work properly, there are several 
steps necessary to format files, perform the spinup (3 stages), and complete the runs.
Below is the necessary workflow with notes about where file paths need to be updated 
for your local machine.

I've tried to note in the workflow whether steps are exectuted ED, R, or shell.  For
the BU computing cluster, there is a queue for long runs, and so most of these steps 
have qsub submission scripts (most are titled submit_[...]) so that you can run these
steps "detached" because most of the steps take hours to days to runs.  

Note: While this repository has the base scripts for the site-level runs, many of the 
      file paths will not line up since this repository was made with the intention of
      helping distribute the effort for the regional runs

--------------------------

##  00. Install ED (github)

The version of ED that we’re using for the PalEON regional runs can be clone from 
github: 
   - 'git clone -b paleon_region_v1 https://github.com/crollinson/ED2.git'

For more information on ED, please scope out the ED Wiki on github:
https://github.com/EDmodel/ED2/wiki

Installation Instructions should can be found here, but are also fairly straight-
forward: https://github.com/EDmodel/ED2/wiki/Quick-start

##### Installing ED requires the following programs/modeles
1. hdf5 library (v1.6.10 or greater)
2. fortran openmpi compiler

##### Basic Installation steps
1. Clone ED using directions above
2. navigate to build folder: $ cd ED2/ED/build/bin
3. create include.mk.opt and place it in the ED2/ED/build/bin folder 
   — A copy of my include.mk.opt file for Linux is included in the 
     MIP2_Region/0_setup folder of this github repository
   — If you are generating your own make file, make sure sure you install using 
     fopenmp to run ED multi-threaded, which makes things MUCH faster
4. generate dependencies: $ ./generate_deps.sh
5. run the install (this may take 5-15+ minutes): ./install.sh 

#### NOTE: on some servers, compiling stalls at ed_state_vars.f90.  If this happens:
1. cancel the install
2. copy and paste the following code and run (compiles ed_state_vars.f90 with different options)
   - `mpif90 -c -DUSE_INTERF=1 -DUSENC=0 -DPC_LINUX1 -DUSE_HDF5=1 -DUSE_COLLECTIVE_MPIO=0 -DUSE_MPIWTIME=1 -FR -O1 -recursive -Vaxlib -traceback  -I../../src/include -I   -DRAMS_MPI ed_state_vars.F90`
3. when that finishes, continue the install (./install.sh)

If you encounter any errors when trying to install, email me and we can try to 
trouble shoot.  Additional problems can also be raised on the ED2 “Issues” on 
Github (https://github.com/EDmodel/ED2/issues).  This is also a great place to 
look first if you encounter issues to see if its a known issue with known solutions.

##### NOTE: there are additional files you'll need to get from the Dietze Lab to run ED.  
I will eventually put these on iPlant, but for now email me and I'll send them to you.  
They're relatively small files.
 
 

##### Running ED will require the following programs & libraries installed and active:
1. hdf5 (v1.6.10 or greater)
2. nco
3. R (packages: ncdf4, zoo, raster, ggplot2, abind, rhdf5, chron, colorspace)
   - rhdf5 will need to be installed from Bioconductor: http://bioconductor.org/packages/release/bioc/html/rhdf5.html

## 0. Format drivers, etc. (R)

This assumes that you have already downloaded the met and environmental drivers from 
iPlant (de.iplantcollaborative.org.  If you do not have access to the drivers, sign 
up for an iPlant account (free) and email your username to a PalEON modeling admin to
get read/write permissions to the folder.

1. Reformat PalEON met drivers for ED by running process_paleon_met_region.R

      note: this step can take a while so you can run process_paleon_met_region_spinup.R 
            to run just the spinup met so you can start the spinup process


## 1. ED initial spin to approximate steady state (bash, ED) 

The first part of the ED spinup protocol requires you to run the model for a long period
of time to get a rought demography distribution and soil carbon flux values to approximate
a steady state.  This part must be done with disturbance off.

start_new_batch.sh should contain everything you need to setup and execute the ED runs. 

*** Note: When people other than myself start running ED for PalEON, we'll need to come up 
with something that creates dummy directories to keep everybody on track and not have 
multiple people running the same cell.

*** Note: This requires the netCDF Operators (nco) software version 4.3.4 
(http://nco.sourceforge.net). At BU, this is loaded as a module (line 30 of 
start_new_batch.sh)

##### File paths, etc. you will need to change in start_new_batch.sh
- line 33: file path to the ED executable
- line 34: file_dir   = where you want the ED outputs to write to (line 34)
- line 35: grid_order = path to the setup file with the order in which PalEON grid cells 
  should be completed
- line 36-38: file_[clay/sand/depth] = these should all be in the regional environmental 
  drivers you downloaded from iPlant
- line 39: n = the number of sites/cells you want to run at a time; this will depend on 
   how many cores you can use per site and how many cores are available to you.  At BU, 1 
   site running with 12 threads takes ~2 weeks from start to finish and I can run 4-5 sites
   at once.
- line 200: Comment out if you do not want the initial spin to be executed with the qsub 
  script immediately. This step works at BU, but may need to be adjusted for whereever you're 
  doing the runs



## 2. Semi-Analytical Solution (SAS) for steady-state approximation (R)

To speed up ED finding (at least somewhat) stable carbon pools, we have implemented the semi-
analytical solution (SAS).  This process uses the equations in the model to approximate steady-
state soil carbon pools and then uses the vegetation structure at given time slices and the 
prescribed disturbance rate to approximate the landscape equilibrium vegetation structure.

More details on this approach can be found in two papers by Xia et al:
1. Xia, J.Y., Y.Q. Luo, Y.-P. Wang, E.S. Weng, and O. Hararuk. 2012. A semi-analytical 
   solution to accelerate spin-up of a coupled carbon and nitrogen land model to 
   steady state. Geoscientific Model Development 5:1259-1271.

2. Xia, J., Y. Luo, Y.-P. Wang, and O. Hararuk. 2013. Traceable components of terrestrial 
   carbon storage capacity in biogeochemical models.  Global Change Biology 19:2104-2116

*** Note: It took a lot of trial & error to get a generalized script that put things even
somewhat close at the site level, so I’m giving things extra long initial spin & post-SAS
transient runs to try and fix that problem.

##### File paths, etc. you will need to change in compile_SAS_runs.R
- line 102: in.base = location of directory where the spin initial files for each site are 
  located; should end with /MIP2_Region/1_spininitial/phase2_spininit.v1
— line 103: out.base = location where the ED initialization files produced by the SAS script 
  will be written; should end with /MIP2_Region/2_SAS/SAS_init_files/



## 3. ED final spin to get final steady state conditions with disturbance settings (bash, ED)

Following the spinup and SAS calculations, the models will need a set of transient runs with 
disturbance turned on to reach a final (somewhat) steady state. Most of the legwork for setting
up individual sites was done for the initial spin, so this should be pretty straight forward.

##### File paths, etc. you will need to change in compile_SAS_runs.R
- line 24: file_base = base file path leading up to wherever this github repository is stored locally


## 4. ED PalEON Runs
