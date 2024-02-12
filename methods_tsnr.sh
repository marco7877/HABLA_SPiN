
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/latest

method=nordic
repo="/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/"
target="/bcbl/home/public/MarcoMotion/Habla_restingState/OHBM_analysis3/"
preproc="func_preproc_nordic/"


mkdir -p ${target}


for sub in {1..5};do
origin="/bcbl/home/public/MarcoMotion/Habla_restingState/sub-00${sub}/ses-1/func_preproc/"
root="/bcbl/home/public/MarcoMotion/Habla_restingState/sub-00${sub}/ses-1/${preproc}"
for task in task-HABLA1200 task-HABLA1700;do

echo analizing subject sub-00${sub}
echo analizing task ${task}
mask=${origin}sub-00${sub}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz
ln_mask=${target}sub-00${sub}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz
	#OPTIMAL COMBINATION TSNR CALCULATION
3dTstat -mean -prefix  ${root}${task}brain_mask/desc-optcom_bold_mean.nii.gz ${root}${task}brain_mask/desc-optcom_bold.nii.gz -overwrite


3dTproject -polort 5 -prefix  ${root}${task}brain_mask/desc-optcom_bold_dt.nii.gz -input ${root}${task}brain_mask/desc-optcom_bold.nii.gz -overwrite


3dcalc -a ${root}${task}brain_mask/desc-optcom_bold_dt.nii.gz -b ${root}${task}brain_mask/desc-optcom_bold_mean.nii.gz -expr 'a+b' -prefix ${root}${task}brain_mask/desc-optcom_bold_dt.nii.gz -overwrite


3dTstat -stdevNOD -prefix  ${root}${task}brain_mask/desc-optcom_bold_std.nii.gz ${root}${task}brain_mask/desc-optcom_bold_dt.nii.gz -overwrite


3dcalc -a ${root}${task}brain_mask/desc-optcom_bold_mean.nii.gz -b ${root}${task}brain_mask/desc-optcom_bold_std.nii.gz -m ${mask} -expr 'm*(a/b)' -prefix ${root}${task}brain_mask/desc-optcom_bold_tsnr_${method}.nii.gz -overwrite


ln -s ${root}${task}brain_mask/desc-optcom_bold_tsnr_${method}.nii.gz ${target}sub-00${sub}_${task}desc-optcom_bold_tsnr_${method}.nii.gz

##
## TODO: quitar la segunda parte. Anidar lo de abajo en . Reiterar. 
## La creación de links se mantiene.
##
	#DENOISED OPTIMAL COMBINATION TSNR CALCULATION
3dTstat -mean -prefix  ${root}${task}brain_mask/desc-optcomDenoised_bold_mean.nii.gz ${root}${task}brain_mask/desc-optcomDenoised_bold.nii.gz -overwrite


3dTproject -polort 5 -prefix  ${root}${task}brain_mask/desc-optcomDenoised_bold_dt.nii.gz -input ${root}${task}brain_mask/desc-optcomDenoised_bold.nii.gz -overwrite


3dcalc -a ${root}${task}brain_mask/desc-optcomDenoised_bold_dt.nii.gz -b ${root}${task}brain_mask/desc-optcomDenoised_bold_mean.nii.gz -expr 'a+b' -prefix ${root}${task}brain_mask/desc-optcomDenoised_bold_dt.nii.gz -overwrite


3dTstat -stdevNOD -prefix  ${root}${task}brain_mask/desc-optcomDenoised_bold_std.nii.gz ${root}${task}brain_mask/desc-optcomDenoised_bold_dt.nii.gz -overwrite


3dcalc -a ${root}${task}brain_mask/desc-optcomDenoised_bold_mean.nii.gz -b ${root}${task}brain_mask/desc-optcomDenoised_bold_std.nii.gz -m ${mask} -expr 'm*(a/b)' -prefix ${root}${task}brain_mask/desc-optcomDenoised_bold_tsnr_${method}.nii.gz -overwrite




ln -s ${root}${task}brain_mask/desc-optcomDenoised_bold_tsnr_${method}.nii.gz ${target}sub-00${sub}_${task}desc-optcomDenoised_bold_tsnr_${method}.nii.gz

ln -s ${mask} ${ln_mask}
echo TSNR calculation done for ${tasks} with ${method} method

done

done

