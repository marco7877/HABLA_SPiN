#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/stable
module load matlab/R2021B

method=$1 # hydra  
preproc=func_preproc_${method}
n_sub=$2

subj=sub-00${n_sub}
repo=/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/
origin=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
output=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}/

magnetization=10

noise=$3 # number of noise volumes

task=$4

save_gfactor=2 # save gfactor map = 1 (saves gfactor and runs nordic); = 2 (saves gfactor and stops)  

nechoes=4
# MAIN

#Check if output durectory exists

if [[ ! -e ${output} ]]; then

	mkdir ${output}

fi

echo "*************************************************************"
# Reference original volumnes
part_mag=${origin}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_dsd.nii.gz

echo "My reference part_mag is: ${part_mag}"

part_phase=${origin}/${subj}_ses-1_${task}_echo-1_part-phase_bold_${method}_dsd.nii.gz

echo "My reference part_phase is: ${part_phase}"

if [[ ! -e ${output}tmp  ]]; then

	mkdir ${output}tmp

fi 

temp_nordic=$(mktemp ${output}tmp/nordicXXXXXX.m)

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
3dZcat $part_mag -prefix ${output}${subj}_ses-1_${task}_echoes_part-mag_bold_${method}_dsd.nii.gz -overwrite

3dZcat $part_phase -prefix ${output}${subj}_ses-1_${task}_echoes_part-phase_bold_${method}_dsd.nii.gz -overwrite

echo "*************************************************************"
echo "addpath(genpath('/bcbl/home/public/MarcoMotion/toolboxes/'));cd '${repo}';ARG.temporal_phase=1;ARG.noise_volume_last=${noise};ARG.phase_filter_width=10;ARG.save_add_info=1;ARG.save_gfactor_map=${save_gfactor};ARG.DIROUT='${output}';NIFTI_NORDIC('${output}${subj}_ses-1_${task}_echoes_part-mag_bold_${method}_dsd.nii.gz','${output}${subj}_ses-1_${task}_echoes_part-phase_bold_${method}_dsd.nii.gz','${subj}_ses-1_${task}_echoes_part-mag_bold_${method}',ARG);" > $temp_nordic

matlab -batch "run('$temp_nordic');exit" 

z_hydra=$(3dinfo -nk ${output}${subj}_ses-1_${task}_echoes_part-phase_bold_${method}.nii 
)

z_orig=$(3dinfo -nk ${origin}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_dsd.nii.gz
)
start=0

finish=$(($z_orig-1))

list_echoes=$( count -digits 1 1 4 )

for n_echoe in $list_echoes

do

	echo "*************************************************************"
	echo "3dZcutup -prefix ${output}${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}.nii.gz -keep ${start} ${finish} ${output}${subj}_ses-1_${task}_echoes_part-mag_bold_${method}_dsd.nii -overwrite"

	3dZcutup -prefix ${output}${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}.nii.gz -keep ${start} ${finish} ${output}${subj}_ses-1_${task}_echoes_part-mag_bold_${method}.nii -overwrite


	start=$(($start+$z_orig))

	finish=$(($finish+$z_orig))
done

ATR=$( 3dAttribute IJK_TO_DICOM_REAL ${origin}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_dsd.nii.gz )

volumes=$(3dinfo -nvi ${origin}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}.nii.gz)

vol=$(($volumes-$noise))

echo "I have original $volumes  volumes but after removing noise we have: $vol"

for n_echoe in $list_echoes

do

	3drefit -atrfloat IJK_TO_DICOM_REAL "${ATR}" ${output}${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}.nii.gz

	# Removing last noise volumes

	echo "removing noise to ${output}/${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}.nii.gz"

	3dcalc -a "${output}${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}.nii.gz[0..${vol}]" -expr 'a' -prefix ${output}${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}.nii.gz -overwrite

done
rm -rf ${output}tmp
