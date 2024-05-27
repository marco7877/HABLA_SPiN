
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/stable

method=$1
sub=$2
tsk=$3
task=tedana_${tsk}
analysis_windows=analysis_03-24
repo="/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/"
target="/bcbl/home/public/MarcoMotion/Habla_restingState/${analysis_windows}/"
preproc="func_preproc_${method}/"


mkdir -p ${target}


origin="/bcbl/home/public/MarcoMotion/Habla_restingState/sub-00${sub}/ses-1/func_preproc_vanilla/"
root="/bcbl/home/public/MarcoMotion/Habla_restingState/sub-00${sub}/ses-1/${preproc}"

echo analizing subject sub-00${sub}
echo analizing task ${tsk}
mask=${origin}sub-00${sub}_ses-1_${tsk}_echo-1_part-mag_brain_mask.nii.gz
ln_mask=${target}sub-00${sub}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz
	
ln -s ${mask} ${ln_mask}
#OPTIMAL COMBINATION TSNR CALCULATION
3dTstat -mean -prefix  ${root}${task}/desc-optcom_bold_mean.nii.gz ${root}${task}/desc-optcom_bold.nii.gz -overwrite

#Estimating spatial smoothness
3dFWHMx -geom -detrend -input ${root}${task}/desc-optcom_bold.nii.gz -mask ${ln_mask} -overwrite -out ${root}${task}/desc-optcom_bold_smoothness.1D


3dTproject -polort 5 -prefix  ${root}${task}/desc-optcom_bold_dt.nii.gz -input ${root}${task}/desc-optcom_bold.nii.gz -overwrite


3dcalc -a ${root}${task}/desc-optcom_bold_dt.nii.gz -b ${root}${task}/desc-optcom_bold_mean.nii.gz -expr 'a+b' -prefix ${root}${task}/desc-optcom_bold_dt.nii.gz -overwrite


3dTstat -stdevNOD -prefix  ${root}${task}/desc-optcom_bold_std.nii.gz ${root}${task}/desc-optcom_bold_dt.nii.gz -overwrite


3dcalc -a ${root}${task}/desc-optcom_bold_mean.nii.gz -b ${root}${task}/desc-optcom_bold_std.nii.gz -m ${mask} -expr 'm*(a/b)' -prefix ${root}${task}/desc-optcom_bold_tsnr_${method}.nii.gz -overwrite


ln -s ${root}${task}/desc-optcom_bold_tsnr_${method}.nii.gz ${target}sub-00${sub}_ses-1_${task}_desc-optcom_bold_tsnr_${method}.nii.gz

ln -s ${root}${task}/desc-optcom_bold_smoothness.1D ${target}sub-00${sub}_ses-1_${task}_desc-optcom_bold_tsnr_${method}.1D
##
## TODO: quitar la segunda parte. Anidar lo de abajo en . Reiterar. 
## La creación de links se mantiene.
##
	#DENOISED OPTIMAL COMBINATION TSNR CALCULATION


3dTstat -mean -prefix  ${root}${task}/desc-optcomDenoised_bold_mean.nii.gz ${root}${task}/desc-optcomDenoised_bold.nii.gz -overwrite

#Estimating spatial smoothness
3dFWHMx -geom -detrend -input ${root}${task}/desc-optcomDenoised_bold.nii.gz -mask ${ln_mask} -overwriten -out ${root}${task}/desc-optcomDenoised_bold_smoothness.1D

3dTproject -polort 5 -prefix  ${root}${task}/desc-optcomDenoised_bold_dt.nii.gz -input ${root}${task}/desc-optcomDenoised_bold.nii.gz -overwrite


3dcalc -a ${root}${task}/desc-optcomDenoised_bold_dt.nii.gz -b ${root}${task}/desc-optcomDenoised_bold_mean.nii.gz -expr 'a+b' -prefix ${root}${task}/desc-optcomDenoised_bold_dt.nii.gz -overwrite


3dTstat -stdevNOD -prefix  ${root}${task}/desc-optcomDenoised_bold_std.nii.gz ${root}${task}/desc-optcomDenoised_bold_dt.nii.gz -overwrite


3dcalc -a ${root}${task}/desc-optcomDenoised_bold_mean.nii.gz -b ${root}${task}/desc-optcomDenoised_bold_std.nii.gz -m ${mask} -expr 'm*(a/b)' -prefix ${root}${task}/desc-optcomDenoised_bold_tsnr_${method}.nii.gz -overwrite




ln -s ${root}${task}/desc-optcomDenoised_bold_tsnr_${method}.nii.gz ${target}sub-00${sub}_ses-1_${task}_desc-optcomDenoised_bold_tsnr_${method}.nii.gz

ln -s ${root}${task}/desc-optcom_boldDenoised_bold_smoothness.1D ${target}sub-00${sub}_ses-1_${task}_desc-optcom_bold_tsnr_${method}.1D
echo TSNR calculation done for ${tasks} with ${method} method

