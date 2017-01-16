#!/bin/bash
input_path='../txt_data'
output_path='../avg_data'

for folder_path in ${input_path}/*
do
    station=`echo ${folder_path} | awk '{split($0,a,"/"); print a[3]}'`
    echo 'Processing '${station}' ...'
    mkdir -p ${output_path}/${station}
    python ../python/day_average.py ${folder_path} ${output_path}/${station}
    rm -rf ${folder_path}
done
