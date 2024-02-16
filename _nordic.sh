#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/latest
module load matlab/R2021B

method=nordic
preproc=func_preproc_${method}
subj=sub-002
repo=/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/
origin=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
output=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
noise=3

# MAIN
if [[ ! -e ${output} ]]; then

	mkdir ${output}

fi

for task in task-HABLA1200 task-HABLA1700
do

	mkdir $output/tmp

	
	
	list_echoes=$( count -digits 1 1 4 )

	for n_echo in ${list_echoes}
	do

		temp_nordic=$(mktemp $output/tmp/nordicXXXXXX.m)

		part_mag=${origin}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}_dsd

		part_phase=${origin}/${subj}_ses-1_${task}_echo-${n_echo}_part-phase_bold_${method}_dsd

		echo "my magnitude volume is: ${part_mag}"

		echo "my nordic file is in: ${temp_nordic}"

		echo "addpath(genpath('/bcbl/home/public/MarcoMotion/toolboxes/')); cd '${repo}'; ARG.temporal_phase=1; ARG.phase_filter_wodth=10; ARG.save_add_info=1; ARG.DIROUT='${output}'; ARG.noise_volume_last=3; NIFTI_NORDIC ('${part_mag}.nii.gz','${part_phase}.nii.gz','${part_mag}',ARG)" > $temp_nordic

		echo "Thermal denoising with NORDIC:  ID ${subj}"

		matlab -batch "run('$temp_nordic');exit" 
		
	done
	rm -rf $output/tmp

	part_mag=${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_dsd
	
	volumes=$(3dinfo -nvi ${part_mag}.nii)

	echo "3dinfo -nvi ${part_mag}.nii"

	vol=$(($volumes-$noise))
	
	echo "I have original $volumes  volumes but after removing noise we have: $vol"

	for n_echo in ${list_echoes}
	do
		part_mag=${output}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}_dsd
		
		echo "removing noise to ${part_mag}.nii"

		3dcalc -a ${part_mag}.nii[0..${vol}] -expr 'a' -prefix ${part_mag}.nii.gz -overwrite

	done
done
