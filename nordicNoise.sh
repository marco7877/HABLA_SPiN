#!/bin/bash -x
#This computes signal that NORDIC cut as thermal noise.
#Calculating diferences between NORDIC and non-NORDIC epi 
epi_input=$1
nordic_input=$2
time_volumes=$3
epi=${epi_input::-7}
nordic=${nordic_input::-7}
3dcalc -a ${epi_input} -b ${nordic_input} -expr 'a-b' -prefix ${epi}_thermal.nii.gz -overwrite
if [[ "$time_volumes" == "true" ]]; then
  #Calculating mean from noise
  3dTstat -mean -prefix ${epi}_mean_thermal.nii.gz ${epi}_thermal.nii.gz z 
  #Calculating std from noise
  3dTstat -stdevNOD -prefix ${epi}_std_thermal.nii.gz ${epi}_thermal.nii.gz -overwrite
  # remove epi thermal
  #Calculating mean from echo raw 
  3dTstat -mean -prefix ${epi}_mean.nii.gz ${epi_input} -overwrite
  #Calculating std from echo raw
  3dTstat -stdevNOD -prefix ${epi}_std.nii.gz ${epi_input} -overwrite
  # remove epi thermal
  #Calculating mean from echo nordic
  3dTstat -mean -prefix ${nordic}_mean.nii.gz ${nordic_input} -overwrite
  #Calculating std from echo nordic
  3dTstat -stdevNOD -prefix ${nordic}_std.nii.gz ${nordic_input} -overwrite
  # calculating mean change
  3dcalc -a  ${nordic}_mean.nii.gz -b ${epi}_mean.nii.gz -expr '(a-b)/b' -prefix ${epi}_nordic-raw_change.nii.gz -overwrite

else

  3dcalc -a ${nordic_input} -b ${epi_input} -expr '(a-b)/b' -prefix ${epi}_nordic-raw_change.nii.gz -overwrite

fi