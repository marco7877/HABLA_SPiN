#!/bin/bash
epi=$1
mask=$2
epi_input=${epi}.nii.gz

#calculating mean from input
echo 3dTstat -mean -prefix ${epi}_mean.nii.gz ${epi_input}
3dTstat -mean -prefix ${epi}_mean.nii.gz ${epi_input}
#
echo 3dTproject -polort 5 -input ${epi_input} -prefix ${epi}_dt.nii.gz
3dTproject -polort 5 -input ${epi_input} -prefix ${epi}_dt.nii.gz
# Putback mean
echo 3dcalc -a ${epi}_dt.nii.gz -b ${epi}_mean.nii.gz -expr 'a+b' -prefix ${epi}_dt.nii.gz -overwrite
3dcalc -a ${epi}_dt.nii.gz -b ${epi}_mean.nii.gz -expr 'a+b' -prefix ${epi}_dt.nii.gz -overwrite
# compute std
echo 3dTstat -stdev NOD -prefix ${epi}_std.nii.gz ${epi}_dt.nii.gz
3dTstat -stdevNOD -prefix ${epi}_std.nii.gz ${epi}_dt.nii.gz
# Compute tSNR map
echo 3dcalc -a ${epi}_mean.nii.gz -b ${epi}_std.nii.gz -m ${mask} -expr 'm*(a/b)' -prefix ${epi}_tsnr.nii.gz
3dcalc -a ${epi}_mean.nii.gz -b ${epi}_std.nii.gz -m ${mask} -expr 'm*(a/b)' -prefix ${epi}_tsnr.nii.gz
