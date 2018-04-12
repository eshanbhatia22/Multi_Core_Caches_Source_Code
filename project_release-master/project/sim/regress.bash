#!/bin/bash
#add passing test cases here
declare -a arr=(
        "read_miss_icache"
        )
#number of times to run each test case
if [[ $# -eq 0 ]]; then
    LIMIT=20
else
    LIMIT=$1
fi


if [! -d logs]; then
    mkdir logs
fi
source ../../setup.bash
./CLEAR_LOGS
./CLEAR
irun -f cmd_line_comp_elab.f

for i in "${arr[@]}"
do
    for ((j=1; j<= LIMIT; j++))
    do
        irun -f sim_cmd_line.f +UVM_TESTNAME=$i -covtest "$i"_"$j" -svseed random
        mv irun.log logs/"$i"_"$j".log
    done
done
./CLEAR
