#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/latest
module load matlab/R2021B

method=$1
preproc=func_preproc_${method}
n_sub=$2
subj=sub-00${n_sub}
repo=/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/
origin=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
output=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
noise=$3

# MAIN
# mkdir -p gonna make a chain of dirextories.  
#if [[ ! -e ${output} ]]; then

	mkdir -p ${output}

#fi

for task in task-HABLA1200 task-HABLA1700
do

	mkdir -p ${output}/gctmp

	
	#TODO: unzip nifti files before running nordic or hydra
	list_echoes=$( count -digits 1 1 4 )
echo "******************************************************************************"
	for n_echo in ${list_echoes}
	do

		temp_nordic=$(mktemp ${output}/gctmp/nordicXXXXXX.m)

		part_mag=${origin}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}_thrm_dsd

		part_mag_out=${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}_dsd
		
		part_phase=${origin}/${subj}_ses-1_${task}_echo-${n_echo}_part-phase_bold_${method}_thrm_dsd

		echo "my magnitude volume is: ${part_mag}"

		echo "my output magnitude volume is: ${part_mag_out}"

		echo "my nordic file is in: ${temp_nordic}"

		echo "addpath(genpath('/bcbl/home/public/MarcoMotion/toolboxes/NORDIC_Raw/'));cd '${repo}';ARG.noise_volume_last=${noise};ARG.temporal_phase=1;ARG.phase_filter_width=10;ARG.save_add_info=1;ARG.DIROUT='${output}/';NIFTI_NORDIC('${part_mag}.nii.gz','${part_phase}.nii.gz','${part_mag_out}',ARG);" > $temp_nordic

		echo "Thermal denoising with NORDIC:  ID ${subj}"
		matlab -batch "run('$temp_nordic');exit" 
		
	done
	rm -rf ${output}/gctmp

echo "******************************************************************************"
	part_mag=${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_dsd
	
	volumes=$(3dinfo -nvi ${output}/${part_mag_out}.nii)

	echo "3dinfo -nvi ${output}/${part_mag_out}.nii"

	vol=$(($volumes-$noise))
	
echo "******************************************************************************"
	echo "I have original $volumes  volumes but after removing noise we have: $vol"

	for n_echo in ${list_echoes}
	do
		part_mag_thrm=${output}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}_dsd
		
echo "******************************************************************************"
		echo "removing noise to ${part_mag_thrm}.nii"

		3dcalc -a ${part_mag_thrm}.nii[0..${vol}] -expr 'a' -prefix ${part_mag_thrm}.nii.gz -overwrite

	done
done
