# ED_PalEON: Scripts to Execute PalEON MIP ED Runs
Christy Rollinson (crollinson@gmail.com)
7 January, 2016


This folder contains all of the scripts necessary to execute the PalEON MIP Phase 2 
regional runs on a cell-by-cell basis.  For this to work properly, there are several 
steps necessary to format files, perform the spinup (3 stages), and complete the runs.
Below is the necessary workflow with notes about where file paths need to be updated 
for your local machine.

Note: While this repository has the base scripts for the site-level runs, many of the 
      file paths will not line up since this repository was made with the intention of
      helping distribute the effort for the regional runs

--------------------------

##  00. Install ED (github)

The version of ED that we’re using for the PalEON regional runs can be clone from 
github: 
$ git clone -b paleon_region_v1 https://github.com/crollinson/ED2.git

For more information on ED, please scope out the ED Wiki on github:
https://github.com/EDmodel/ED2/wiki

Installation Instructions should can be found here, but are also fairly straight-
forward: https://github.com/EDmodel/ED2/wiki/Quick-start

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

If you encounter any errors when trying to install, email me and we can try to 
trouble shoot.  Additional problems can also be raised on the ED2 “Issues” on 
Github (https://github.com/EDmodel/ED2/issues).  This is also a great place to 
look first if you encounter issues to see if its a known issue with known solutions.


## 0. Format drivers, etc.

This assumes that you have already downloaded the met and environmental drivers from 
iPlant (de.iplantcollaborative.org.  If you do not have access to the drivers, sign 
up for an iPlant account (free) and email your username to a PalEON modeling admin to
get read/write permissions to the folder.

1. Execute


## 1. ED initial spin to approximate steady state (ED, bash) 

The first part of the ED spinup protocol requires you to run the model for a long period
of time to get a rought demography distribution and soil carbon flux values to approximate
a steady state.  This part must be done with disturbance off.

##### File paths you will need to change in start_new_batch.sh
- file_dir   = where you want the ED outputs to write to)
- grid_order = path to the setup file with the order in which PalEON grid cells should be completed
- file_[clay/sand/depth] = these should all be in the regional environmental drivers you downloaded from iPlant


## 2. Semi-Analytical Solution (SAS) for steady-state approximation (R)



## 3. ED final spin to get final steady state conditions with disturbance settings (ED, bash)


## 4. ED PalEON Runs
