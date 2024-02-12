#!/bin/bash -x


id=$1
target_dir=ME-ICA_nordic/task-HABLA1200brain_mask/
bids=/bcbl/home/public/MarcoMotion/Habla_restingState/sub-00${id}/ses-1/
epi_input=$2
mask=$3
mask_ext=$4
epi=${epi_input::-7}


#calculating mean from input
3dTstat -mean -prefix ${epi}_mean.nii.gz ${epi_input} -overwrite


#
3dTproject -polort 5 -input ${epi_input} -prefix ${epi}_dt.nii.gz -overwrite


# Putback mean
3dcalc -a ${epi}_dt.nii.gz -b ${epi}_mean.nii.gz -expr 'a+b' -prefix ${epi}_dt.nii.gz -overwrite


# compute std
3dTstat -stdevNOD -prefix ${epi}_std.nii.gz ${epi}_dt.nii.gz -overwrite


# Compute tSNR map
3dcalc -a ${epi}_mean.nii.gz -b ${epi}_std.nii.gz -m ${mask} -expr 'm*(a/b)' -prefix ${epi}_tsnr_${mask_ext}.nii.gz -overwrite


#remove std map
rm -rf ${epi}_std.nii.gz ${epi}_mean.nii.gz
done
