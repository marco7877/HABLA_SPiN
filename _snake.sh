#!/bin/bashv
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/stable
module load matlab/R2021B

set -e 
set -x

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

save_gfactor=1 # save gfactor map = 1 (saves gfactor and runs nordic); = 2 (saves gfactor and stops)  

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


if [[ ! -e ${output}tmp  ]]; then

	mkdir ${output}tmp

fi 

temp_nordic=$(mktemp ${output}tmp/nordicXXXXXX.m)

# make a list from 1 to 4 with 1 length digits


# Creating a shuffle between echoes (TR1E1 TR1E2 TR1E3 TR1E4 TR2E1 ...)

nTR=$(3dinfo -nt ${part_mag})

nTRm1=$((${nTR} - 1))

nTRx4=$((${nTR} * 4 -1))

for n_echo in $( count -digits 1 2 4 )
do

	part_mag=${part_mag}" "${origin}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}_dsd.nii.gz

done

3dTcat -overwrite -prefix ${output}${subj}_ses-1_${task}_echoes_part-mag_bold_${method}_dsd.nii.gz ${part_mag} 

if [[ -e ${output}${subj}_ses-1_${task}_echo-shuffle_part-mag_bold_${method}_dsd.1D  ]]; then

	rm ${output}${subj}_ses-1_${task}_echo-shuffle_part-mag_bold_${method}_dsd.1D

fi
for ii in $(count 0 ${nTRm1});do shuffle_list+=$(count ${ii} ${nTRx4} ${nTR}); done

echo "${shuffle_list}"


echo "${shuffle_list}">${output}${subj}_ses-1_${task}_echo-shuffle_part-mag_bold_${method}_dsd.1D



3dTcat -overwrite -prefix ${output}${subj}_ses-1_${task}_echo-shuffle_part-mag_bold_${method}_dsd.nii.gz ${output}${subj}_ses-1_${task}_echoes_part-mag_bold_${method}_dsd.nii.gz"[1dcat ${output}${subj}_ses-1_${task}_echo-shuffle_part-mag_bold_${method}_dsd.1D]"

part_mag_out=${subj}_ses-1_${task}_echo-shuffle_part-mag_bold_${method}N

echo "*************************************************************"
echo "addpath(genpath('/bcbl/home/public/MarcoMotion/toolboxes/'));cd '${repo}';ARG.temporal_phase=1;ARG.magnitude_only=1;ARG.noise_volume_last=${noise};ARG.phase_filter_width=10;ARG.save_add_info=1;ARG.save_gfactor_map=${save_gfactor};ARG.DIROUT='${output}';NIFTI_NORDIC('${output}${subj}_ses-1_${task}_echo-shuffle_part-mag_bold_${method}_dsd.nii.gz','${output}${subj}_ses-1_${task}_echo-shuffle_part-mag_bold_${method}_dsd.nii.gz','${part_mag_out}',ARG);" > $temp_nordic

matlab -batch "run('$temp_nordic');exit" 


gzip -f ${output}${part_mag_out}.nii


nTRshuf=$(3dinfo -nt ${output}${part_mag_out}.nii.gz)
nTRshuf=$((nTRshuf - ${noise}))
nTRshuf=$((nTRshuf - 1))
list_echoes=$(count -digit 1 1 4)
for n_echo in ${list_echoes}
do
	current_echo=$((n_echo - 1)) 
	3dcalc -a "${output}${part_mag_out}.nii.gz[${current_echo}..${nTRshuf}(${nechoes})]" -expr 'a' \
		-prefix "${output}${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}.nii.gz" -overwrite
done
