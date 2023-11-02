#!/bin/bash
###
# @author: Marco Flores-Coronado
# @github: marco7877
###

target_dir=func_preproc_cipactli
 
for id in $(seq 1 5);
do
#id=1
fs_dir=/bcbl/home/public/MarcoMotion/Habla_restingState/freesurfer/sub-00${id}/SUMA/

bids=/bcbl/home/public/MarcoMotion/Habla_restingState/sub-00${id}/ses-1/

brain_mask=${bids}func_preproc/sub-00${id}_ses-1_task-HABLA1200_echo-1_part-mag_brain_mask.nii.gz

anat_gmmask=${bids}${target_dir}/sub-00${id}_ses-1_task-HABLA1200_echo-1_part-anat_gm_mask.nii.gz

epi_gmmask=${bids}${target_dir}/sub-00${id}_ses-1_task-HABLA1200_echo-1_part-epi_gm_mask.nii.gz

epi_wmmask=${bids}${target_dir}/sub-00${id}_ses-1_task-HABLA1200_echo-1_part-epi_wm_mask.nii.gz

anat_norm=${bids}${target_dir}/sub-00${id}_ses-1_acq-norm_sk-str_T1w.nii.gz

sbref_echo1=${bids}${target_dir}/sub-00${id}_ses-1_task-HABLA1200_echo-1_part-mag_sbref.nii.gz

sbref_masked=${bids}${target_dir}/sub-00${id}_ses-1_task-HABLA1200_echo-1_part-mag_sbref-masked.nii.gz

anat_wmmask=${bids}${target_dir}/sub-00${id}_ses-1_task-HABLA1200_echo-1_part-anat_wm_mask.nii.gz

tedana_output_dir=${bids}${target_dir}/task-HABLA1200brain_mask/

output_masked=${bids}${target_dir}/sub-00${id}_task-HABLA1200_masked_epi

################################################################################
### making simbolic link of gm segment mask from freesurfer
ln -s ${fs_dir}aparc.a2009s+aseg_REN_gm.nii.gz ${anat_gmmask} #simbolic link

ln -s ${bids}func/sub-00${id}_ses-1_task-HABLA1200_echo-1_part-mag_sbref.nii.gz ${sbref_echo1}

ln -s ${fs_dir}norm.nii.gz ${anat_norm}

ln -s ${fs_dir}wm.seg.nii.gz ${anat_wmmask}

ln -sf ${tedana_output_dir}desc-optcomDenoised_bold_tsnr_brain.nii.gz  ${bids}${target_dir}/task-HABLA1200brain_mask_desc-optcomDenoised_bold_tsnr_brain.nii.gz 

ln -sf ${tedana_output_dir}desc-optcomDenoised_bold.nii.gz  ${bids}${target_dir}/task-HABLA1200brain_mask_desc-optcomDenoised_bold.nii.gz 

3dcalc -a ${sbref_echo1} -b ${brain_mask} -expr 'a*b' -prefix ${bids}func_preproc/sub-00${id}_ses-1_task-HABLA1200_echo-1_part-mag_sbref-masked.nii.gz -overwrite

ln -sf ${bids}func_preproc/sub-00${id}_ses-1_task-HABLA1200_echo-1_part-mag_sbref-masked.nii.gz ${sbref_masked}

3dcalc -a ${anat_gmmask} -expr 'step(a)' -prefix ${anat_gmmask} -overwrite #from multinomial to binary

3dcalc -a ${anat_wmmask} -expr 'step(a)' -prefix ${anat_wmmask} -overwrite #from multinomial to binary

#not run because mask gets worse
3dmask_tool -dilate_inputs 1 -1 -input ${anat_gmmask} -prefix ${bids}${target_dir}/sub-00${id}_ses-1_task-HABLA1200_echo-1_part-anat_gm_mask.nii.gz -overwrite

3dmask_tool -dilate_inputs 1 -1 -input ${anat_wmmask} -prefix ${bids}${target_dir}/sub-00${id}_ses-1_task-HABLA1200_echo-1_part-anat_wm_mask.nii.gz -overwrite

################################################################################
#getting tranformation matrix from fresurfer normalized t1 to sbref echo 1

cd ${bids}${target_dir}

align_epi_anat.py -epi ${sbref_masked} -anat ${anat_norm} -epi_base 0 -big_move -save_Al_in -anat2epi -suffix _norm_anat2epi -anat_has_skull no -volreg off -tshift off -epi_strip None

3dAllineate -overwrite -base ${sbref_masked} -input ${anat_gmmask} -final cubic -1Dmatrix_apply sub-00${id}_ses-1_acq-norm_sk-str_T1w_norm_anat2epi_mat.aff12.1D -prefix ${epi_gmmask} -overwrite

3dAllineate -overwrite -base ${sbref_masked} -input ${anat_wmmask} -final cubic -1Dmatrix_apply sub-00${id}_ses-1_acq-norm_sk-str_T1w_norm_anat2epi_mat.aff12.1D -prefix ${epi_wmmask} -overwrite

3dresample -rmode NN -master ${sbref_masked} -input ${epi_gmmask} -prefix ${epi_gmmask} -overwrite 
3dresample -rmode NN -master ${sbref_masked} -input ${epi_wmmask} -prefix ${epi_wmmask} -overwrite 
################################################################################
# upsampling mask to same length as epi volume

#3dcalc -a ${epi_gmmask} -b ${bids}${target_dir}/task-HABLA1200brain_mask_desc-optcomDenoised_bold.nii.gz -expr 'a*step(b)' -prefix ${epi_gmmask} -overwrite

#3dcalc -a ${epi_wmmask} -b ${bids}${target_dir}/task-HABLA1200brain_mask_desc-optcomDenoised_bold.nii.gz -expr 'a*step(b)' -prefix ${epi_wmmask} -overwrite

################################################################################
## masking opt com and opt com denoised with gm and wm masks

3dcalc -a ${epi_gmmask} -b ${bids}${target_dir}/task-HABLA1200brain_mask_desc-optcomDenoised_bold.nii.gz -expr 'a*b' -prefix ${output_masked}_gm_ocDenoised.nii.gz -overwrite

3dcalc -a ${epi_wmmask} -b ${bids}${target_dir}/task-HABLA1200brain_mask_desc-optcomDenoised_bold.nii.gz -expr 'a*b' -prefix ${output_masked}_wm_ocDenoised.nii.gz -overwrite

3dcalc -a ${epi_gmmask} -b ${bids}${target_dir}/task-HABLA1200brain_mask_desc-optcomDenoised_bold_tsnr_brain.nii.gz -expr 'a*b' -prefix ${output_masked}_gm_ocDenoised_tsnr.nii.gz -overwrite

3dcalc -a ${epi_wmmask} -b ${bids}${target_dir}/task-HABLA1200brain_mask_desc-optcomDenoised_bold_tsnr_brain.nii.gz -expr 'a*b' -prefix ${output_masked}_wm_ocDenoised_tsnr.nii.gz -overwrite
done
