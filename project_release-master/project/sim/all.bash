#!/bin/bash
#add passing test cases here
declare -a arr=(
        "read_miss_icache"
        )

if [! -d logs]; then
    mkdir logs
fi
source ../../setup.bash
./CLEAR_LOGS
./CLEAR
irun -f cmd_line_comp_elab.f

for i in "${arr[@]}"
do
    irun -f sim_cmd_line.f +UVM_TESTNAME=$i -svseed 1 -covtest "$i"
    mv irun.log logs/"$i".log
done
./CLEAR
