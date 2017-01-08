#!/bin/bash
input_path='../seis_data'
output_path='../txt_data'

for folder in ${input_path}/*
do 
	for file in ${folder}/*
	do
		output_f=`echo ${file} | awk '{split($0,a,"/"); print a[4]}'`
		python ../python/read_seis.py ${file} > ${output_path}/${output_f}.txt
	done
done

