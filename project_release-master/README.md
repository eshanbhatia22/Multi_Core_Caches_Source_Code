# Environment setup
> source setup.bash

# compilation and elaboration
> cd ./project/sim/
> irun -f cmd_line_comp_elab.f

# running a test case in GUI
> cd ./project/sim/
> irun -f run_mc.f <+UVM_TESTNAME=test_case_name>

## File Organization
• design – folder that contains all cache design files. "cache_top.sv" is the top level file. Except cache_top.sv all the files in design folder are encrypted.

• design/common – folder that contains component design files shared by level 1 and level 2 cache.

• design/lv1 – folder that contains component design files which exclusively belongs to level 1 cache.

• design/lv2 – folder that contains component design files which exclusively belongs to level 2 cache.

• sim – folder that contains files to control simulation and store results.

• gold – folder that contains the golden arbiter, and memory.

• uvm – folder that contains test bench files: driver, monitor, scoreboard, transactions, packet classes and checkers. top level test bench file: "top.sv"

• test – folder that contains test case files: virtual sequences and test classes.

## TestBench Instructions
  1. Currently the design has all 4 cores enabled.

  2. Level 1 and level 2 cache are all empty at the beginning but memory is pre-filled with initial data. The value of a data block in
  the memory depend on bit[3] of its address.
  data = addr_bus_lv2_mem[3] ? 32'h5555_aaaa : 32'haaaa_5555;
  Once you write back to the memory, it will become the value you have written.

## To dump waves, you can follow the procedure we adopted in labs, 
 1. Create waves.tcl in uvm/ directory.
 2. Add below line of code in waves.tcl 
>	database -open waves -into waves.shm -default

>	probe -create top -depth all -tasks -functions -all -database waves -waveform

>	run

 3. Open your sim cmf files:
>	sim_cmd_line.f: Add below line

>   	-input ../uvm/waves.tcl

>	run_mc.f: Add below line

>   	-input ../uvm/waves.tcl


## Github Commands
## To clone:
	git clone <url>
## To checkout particular branch number:
	git checkout <branch number>
## To upload a new repository on github:
	git init
	git add .
	git status
	git commit -m "comment"
	git remote add origin <URL for repo>
	git push -u origin master
## To add a new file or modify some file in existing repo:
	git init
	git add .
	git status
	git commit -m "added this change"
	git push
