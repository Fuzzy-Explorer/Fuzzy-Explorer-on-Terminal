#!/bin/bash
arr=(a b c d)
echo ${arr[@]}
unset arr[3]
echo ${arr[@]}
