#!/bin/bash

#how to run cipactli
sub='sub-001'
root="/bcbl/home/public/MarcoMotion/Habla_restingState/${sub}/ses-1/"
repo="/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/"
tsnr_echo=(2 3)
task="task-HABLA1200"

echo "cipactli.py --echo1 ${root}func_preproc/${sub}_ses-1_${task}_echo-1_part-mag_bold_dsd.nii.gz --source_sbref ${root}func/${sub}_ses-1_${task}_echo-1_part-mag_sbref.nii.gz --output_dir func_preproc_cipactli/ --echoes 4 --TE "11 28 45 61" --mask ${root}func_preproc/${sub}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz"


python cipactli.py --echo1 ${root}func_preproc/${sub}_ses-1_${task}_echo-1_part-mag_bold_dsd.nii.gz --source_sbref ${root}func/${sub}_ses-1_${task}_echo-1_part-mag_sbref.nii.gz --echoes 4 --TE "11 28 45 61" --mask ${root}func_preproc/${sub}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz


echo "Calculating tsnr from source echo-1 and echo-2"

for echo in ${tsnr_echo}
do
  ./tsnr.sh ${root}func_preproc_cipactli/${sub}_ses-1_${task}_echo-${echo}_part-mag_bold_cipactli_mcf_al.nii.gz ${root}func_preproc/${sub}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz brain
done

echo "Calculating tsnr for ME-ICA optimal combination"

./tsnr.sh ${root}func_preproc_cipactli/${task}brain_mask/desc-optcom_bold.nii.gz ${root}func_preproc/${sub}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz brain

echo "Calculating tsnr for ME-ICA optimal combination - rejected components (denoised)"

./tsnr.sh ${root}func_preproc_cipactli/${task}brain_mask/desc-optcomDenoised_bold.nii.gz ${root}func_preproc/${sub}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz brain

echo "Calculating %difference in S0 and T2* maps"

 ./nordicNoise.sh ${root}func_preproc_cipactli/${task}brain_mask/T2starmap.nii.gz   ${root}ME-ICA/${task}brain_mask/T2starmap.nii.gz False

 ./nordicNoise.sh ${root}func_preproc_cipactli/${task}brain_mask/S0map.nii.gz   ${root}ME-ICA/${task}brain_mask/S0map.nii.gz False

echo "Calculating thermal noise maps"
for echo in ${tsnr_echo}
do
  ./nordicNoise.sh ${root}func_preproc/${sub}_ses-1_${task}_echo-${echo}_part-mag_bold_mcf_al.nii.gz  ${root}func_preproc_cipactli/${sub}_ses-1_${task}_echo-${echo}_part-mag_bold_cipactli_mcf_al.nii.gz true
done
