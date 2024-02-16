#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/latest
module load matlab/R2021B

method=hydra
preproc=func_preproc_${method}
subj=sub-002
repo=/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/
origin=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
output=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
magnetization=10
noise=3
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

	part_phase=${origin}/${subj}_ses-1_${task}_echo-1_part-phase_bold_${method}_dsd.nii.gz

	echo "My reference part_phase is: ${part_phase}"

	if [[ ! -e ${output}/tmp  ]]; then

		mkdir ${output}/tmp

	fi 

	temp_nordic=$(mktemp $output/tmp/nordicXXXXXX.m)

# make a list from 1 to 4 with 1 length digits

	list_echoes=$( count -digits 1 2 4 )

	echo "List of echoes is ${list_echoes}"

	for n_echo in ${list_echoes}

	do

		mag=$part_mag" "${origin}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}_dsd.nii.gz

		phase=$part_phase" "${origin}/${subj}_ses-1_${task}_echo-${n_echo}_part-phase_bold_${method}_dsd.nii.gz

		part_mag=$mag

		part_phase=$phase

	done


	echo "Magnitude volumes to concatenate are: $part_mag"

	echo "Phase volumes to concatenate are: $part_phase"

	3dZcat $part_mag -prefix $output/${subj}_ses-1_${task}_echoes_part-mag_bold_${method}_dsd.nii.gz -overwrite

	3dZcat $part_phase -prefix $output/${subj}_ses-1_${task}_echoes_part-phase_bold_${method}_dsd.nii.gz -overwrite

	echo "addpath(genpath('/bcbl/home/public/MarcoMotion/toolboxes/')); cd '${repo}'; ARG.temporal_phase=1; ARG.phase_filter_wodth=10; ARG.save_add_info=1; ARG.DIROUT='${output}'; ARG.noise_volume_last=3; NIFTI_NORDIC ('$output/${subj}_ses-1_${task}_echoes_part-mag_bold_${method}_dsd.nii.gz','$output/${subj}_ses-1_${task}_echoes_part-phase_bold_${method}_dsd.nii.gz','$output/${subj}_ses-1_${task}_echoes_part-mag_bold_${method}_dsd',ARG)" > $temp_nordic

	matlab -batch "run('$temp_nordic');exit" 

	z_hydra=$(3dinfo -nk $output/${subj}_ses-1_${task}_echoes_part-phase_bold_${method}_dsd.nii 
)

	z_orig=$(3dinfo -nk ${origin}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_dsd.nii.gz
)
	start=0

	finish=$(($z_orig-1))

	list_echoes=$( count -digits 1 1 4 )

	for n_echoe in $list_echoes

	do

		3dZcutup -prefix ${output}/${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}_dsd.nii.gz -keep ${output}/${subj}_ses-1_${task}_echoes_part-phase_bold_${method}_dsd.nii[${start}..${finish}] -overwrite

		start=$(($start+$z_orig))

		finish=$(($finish+$z_orig))
	done

	ATR=$( 3dAttribute IJK_TO_DICOM_REAL ${origin}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_dsd.nii.gz )
            
	volumes=$(3dinfo -nvi ${origin}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_dsd.nii.gz)

	vol=$(($volumes-$noise))

	echo "I have original $volumes  volumes but after removing noise we have: $vol"

	for n_echoe in $list_echoes

	do

		3drefit -atrfloat IJK_TO_DICOM_REAL '${ATR}' ${output}/${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}_dsd.nii.gz

# Removing last noise volumes

		echo "removing noise to ${output}/${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}_dsd.nii.gz"
	
		3dcalc -a ${output}/${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}_dsd.nii.gz[0..${vol}] -expr 'a' -prefix ${output}/${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}_dsd.nii.gz -overwrite

	done
done
rm -rf $output/tmp
