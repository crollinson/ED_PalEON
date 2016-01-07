# ED_PalEON: Scripts to Execute PalEON MIP ED Runs

Christy Rollinson (crollinson@gmail.com)

7 January, 2016

--------------------------

This folder contains all of the scripts necessary to execute the PalEON MIP Phase 2 
regional runs on a cell-by-cell basis.  For this to work properly, there are several 
steps necessary to format files, perform the spinup (3 stages), and complete the runs.
Below is the necessary workflow with notes about where file paths need to be updated 
for your local machine.

Note: While this repository has the base scripts for the site-level runs, many of the 
      file paths will not line up since this repository was made with the intention of
      helping distribute the effort for the regional runs


--------------------------
###  0. Install ED (github)

The version of ED that we’re using for the PalEON regional runs can be clone from 
github: 
$ git clone -b paleon_region_v1 https://github.com/crollinson/ED2.git

For more information on ED, please scope out the ED Wiki on github:
https://github.com/EDmodel/ED2/wiki

Installation Instructions should can be found here, but are also fairly straight-
forward: https://github.com/EDmodel/ED2/wiki/Quick-start

Basic Installation steps
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

--------------------------
