#!/bin/bash
echo "PASS"
grep -l "Test PASS" ./*log
echo "FAIL"
grep -l "Test FAIL" ./*log
