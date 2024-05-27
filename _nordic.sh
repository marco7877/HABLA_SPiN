#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/stable
module load matlab/R2021B

method=$1 # nordic, hydra 
preproc=func_preproc_${method}
n_sub=$2
subj=sub-00${n_sub}

# define folders 
repo=/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/
origin=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
output=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}

noise=$3 # number of noise volumes

task=$4

save_gfactor=2 # save gfactor map = 1 (saves gfactor and runs nordic); = 2 (saves gfactor and stops)  

# MAIN

# mkdir -p gonna make a chain of dirextories.  
#if [[ ! -e ${output} ]]; then

mkdir -p ${output}

#fi


mkdir -p ${output}/gctmp # define temporary folder to save temporary matlab scripts 

# TODO: Change nordic.m to return compressed files them)
list_echoes=$( count -digits 1 1 4 )
echo "******************************************************************************"
for n_echo in ${list_echoes}
do

	temp_nordic=$(mktemp ${output}/gctmp/nordicXXXXXX.m)

	part_mag=${origin}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}_dsd

	part_mag_out=${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}N

	part_phase=${origin}/${subj}_ses-1_${task}_echo-${n_echo}_part-phase_bold_${method}_dsd

	echo "my magnitude volume is: ${part_mag}"

	echo "my output magnitude volume is: ${part_mag_out}"

	echo "my nordic file is in: ${temp_nordic}"

	echo "addpath(genpath('/bcbl/home/public/MarcoMotion/toolboxes/NORDIC_Raw/'));cd '${repo}';ARG.noise_volume_last=${noise};ARG.temporal_phase=1;ARG.phase_filter_width=10;ARG.save_add_info=1;ARG.save_gfactor_map=${save_gfactor};ARG.DIROUT='${output}/';NIFTI_NORDIC('${part_mag}.nii.gz','${part_phase}.nii.gz','${part_mag_out}',ARG);" > $temp_nordic

	echo "Thermal denoising with NORDIC:  ID ${subj}"
			matlab -batch "run('$temp_nordic');exit" 

			gzip -f ${output}/${part_mag_out}.nii
done
#rm -rf ${output}/gctmp

echo "******************************************************************************"

volumes=$(3dinfo -nvi ${output}/${part_mag_out}.nii.gz)

echo "3dinfo -nvi ${output}/${part_mag_out}.nii.gz"

vol=$(($volumes-$noise))

echo "Original data ${volumes} volumes, but after removing noise volumes it has ${vol} volumes"

echo "******************************************************************************"


for n_echo in ${list_echoes}
do
	part_mag_thrm=${output}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}N

	part_mag_thrm_trimmed=${output}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}
	echo "******************************************************************************"
	echo "removing noise volumes to ${part_mag_thrm}.nii"

	3dcalc -a "${part_mag_thrm}.nii.gz[0..${vol}]" -expr 'a' -prefix ${part_mag_thrm_trimmed}.nii.gz -overwrite 
done
