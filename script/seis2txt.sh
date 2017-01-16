#!/bin/bash
input_path='../data'
output_path='../txt_data'

for folder_path in ${input_path}/*
do 
    folder=`echo ${folder_path} | awk '{split($0,a,"/"); print a[3]}'`
    echo 'Processing '${folder}' ...'
    mkdir -p ${output_path}/${folder}
    for file_path in ${folder_path}/*
    do
    	output_f=`echo ${file_path} | awk '{split($0,a,"/"); print a[4]}'`
    	python ../python/read_seis.py ${file_path} > ${output_path}/${folder}/${output_f}.txt
    done
    rm -rf ${folder_path}
done
