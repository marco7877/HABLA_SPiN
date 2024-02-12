#!/usr/bin/bash

###### variables

#declare -a lstMethod
lstMethod=("func_preproc_cipactli" "ME-ICA__" "ME-ICA_nordic" )
target_dir= /bcbl/home/public/MarcoMotion/Habla_restingState/visualization_subjects2/
bids=/bcbl/home/public/MarcoMotion/Habla_restingState/

mkdir target_dir


#### TODO: This is súuper messy! LoL

for id in $(seq 1 5);
do
for method in "func_preproc_cipactli" "ME-ICA__" "ME-ICA_nordic"
do
for echo in $(seq 1 4);
do

subj_mag=${bids}sub-00${id}/ses-1/${method}/sub-00${id}_task-HABLA1200_masked_epi_gm_ocDenoised.nii.gz
ln_mag=${target_dir}sub-00${id}_ses-1_${method}_masked_epi_gm_ocDenoised.nii.gz
subj_tsnr=${bids}sub-00${id}/ses-1/${method}/sub-00${id}_task-HABLA1200_masked_epi_gm_ocDenoised_tsnr.nii.gz
ln_tsnr==$target_dir}sub-00${id}_ses-1_${method}_masked_epi_gm_ocDenoised_tsnr.nii.gz

ln -s  ${subj_mag} ${ln_mag}

ln -s  ${subj_tsnr} ${ln_tsnr}
done
done

done
