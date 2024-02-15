#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/latest
module load matlab/R2021B
module load fsl/6.0.3

method=hydra
preproc=func_preproc_${method}
subj=sub-005
repo=/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/
origin=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
output=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
input=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/func
magnetization=10
noise=0
echoes=4

# MAIN

#Check if output durectory exists

if [[ ! -e ${output} ]]; then

	mkdir ${output}

fi

for task in task-HABLA1200 task-HABLA1700
do
# Reference original volumnes
	part_mag=${origin}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_dsd.nii.gz
	echo "My reference part_mag is: ${part_mag}"
	sbref=${input}/${subj}_ses-1_${task}_echo-1_part-mag_sbref.nii.gz


	if [[ ! -e ${output}/tmp  ]]; then

		mkdir ${output}/tmp

	fi 


	3dvolreg -overwrite -Fourier -base ${sbref} -1Dfile  ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf.1D -1Dmatrix_save ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf.aff12.1D -prefix ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf.nii.gz ${part_mag}
	1d_tool.py -infile ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf.1D -demean -write ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf_demean.1D -overwrite
	1d_tool.py -infile ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf_demean.1D -derivative -demean -write ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf_deriv1.1D -overwrite
	1d_tool.py -infile ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf.1D -derivative -collapse_cols euclidean_norm -write ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf_enorm.1D -overwrite

	list_echoes=$( count -digits 1 1 4 )

	for n_echoe in $list_echoes
	do

	part_mag=${origin}/${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}_dsd.nii.gz

        3dAllineate -overwrite -base ${sbref} -final cubic -1Dmatrix_apply ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf.aff12.1D -prefix ${output}/${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}_mcf_al.nii.gz ${part_mag}
	done
done
