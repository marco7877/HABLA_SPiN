#!/bin/bash -x

epi_input=$1
mask=$2
mask_ext=$3
epi=${epi_input::-7}
#echo "${epi}"
#calculating mean from input
#echo 3dTstat -mean -prefix ${epi}_mean.nii.gz ${epi_input}
3dTstat -mean -prefix ${epi}_mean.nii.gz ${epi_input} -overwrite
#
#echo 3dTproject -polort 5 -input ${epi_input} -prefix ${epi}_dt.nii.gz
3dTproject -polort 5 -input ${epi_input} -prefix ${epi}_dt.nii.gz -overwrite
# Putback mean
#echo 3dcalc -a ${epi}_dt.nii.gz -b ${epi}_mean.nii.gz -expr 'a+b' -prefix ${epi}_dt.nii.gz -overwrite
3dcalc -a ${epi}_dt.nii.gz -b ${epi}_mean.nii.gz -expr 'a+b' -prefix ${epi}_dt.nii.gz -overwrite
# compute std
#echo 3dTstat -stdev NOD -prefix ${epi}_std.nii.gz ${epi}_dt.nii.gz
3dTstat -stdevNOD -prefix ${epi}_std.nii.gz ${epi}_dt.nii.gz -overwrite
# Compute tSNR map
#echo 3dcalc -a ${epi}_mean.nii.gz -b ${epi}_std.nii.gz -m ${mask} -expr 'm*(a/b)' -prefix ${epi}_tsnr.nii.gz
3dcalc -a ${epi}_mean.nii.gz -b ${epi}_std.nii.gz -m ${mask} -expr 'm*(a/b)' -prefix ${epi}_tsnr_${mask_ext}.nii.gz
#remove std map
rm -rf ${epi}_std.nii.gz ${epi}_mean.nii.gz