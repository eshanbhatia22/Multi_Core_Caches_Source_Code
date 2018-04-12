#!/bin/bash
source ../../setup.bash

# Merge coverage reports of various tests to ALL. Load and generate HTML based coverage report for all metrics
# top is the module name in top.sv (top-level module)
imc -execcmd "merge * -out ALL;
              load -run cov_work/scope/ALL/;
              report -html -overwrite -out report_cov_multicore -detail -metrics all -all"
              #report_metrics -out report_cov_multicore -detail -metrics all:block:expression"
              # add below for only instances
              # -inst top
