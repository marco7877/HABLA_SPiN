#!/bin/bash
#This computes signal that NORDIC cut as thermal noise.
#Calculating diferences between NORDIC and non-NORDIC epi 
epi=$1
nordic=$2
if["${epi}" ==*.nii.gz]: then
	epi=${epi::-7}
echo 3dcalc -a ${epi}.nii.gz -b ${nordic} -expr 'a-b' -prefix ${epi}thermal.nii.gz
3dcalc -a ${epi}.nii.gz -b ${nordic} -expr 'a-b' -prefix ${epi}thermal.nii.gz
#Calculating mean from noise
echo 3dTstat -mean -prefix ${epi}mean-thermal.nii.gz ${epi}thermal.nii.gz
3dTstat -mean -prefix ${epi}mean-thermal.nii.gz ${epi}thermal.nii.gz 
#Calculating std from noise
3dTstat -stdevNOD -prefix ${epi}std-thermal.nii.gz ${epi}thermal.nii.gz
