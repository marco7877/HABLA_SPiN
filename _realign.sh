#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/stable
module load fsl/6.0.3

method=$1 # vanilla, nordic, hydra 
n_subj=$2
task=$3
preproc=func_preproc_${method}

# define folders
subj=sub-00${n_subj}
repo=/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/
origin=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
output=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
input=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/func

nechoes=4


# DSD extention for the volumes without thermal noise (nordic, hydra) or vainilla (ME)

ext=.nii.gz
# MAIN

#Check if output durectory exists

if [[ ! -e ${output} ]]; then

	mkdir ${output}

fi

# Reference original volumnes
part_mag=${origin}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}${ext}
echo "My reference part_mag is: ${part_mag}"
sbref=${input}/${subj}_ses-1_${task}_echo-1_part-mag_sbref${ext}
# define name for symbolic link 
sbref_ln=${output}/${subj}_ses-1_${task}_echo-1_part-mag_sbref${ext}

if [[ ! -e ${sbref_ln} ]]; then
	ln -s ${sbref} ${sbref_ln}
fi

#TODO. Add indentation with | to split loong commands
#  Make variables more clean. let only the extension after variable, i.e., ${output_mcf}_al-nii.gz
3dvolreg -overwrite -Fourier -base ${sbref_ln} \
	-1Dfile  ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf.1D \
	-1Dmatrix_save ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf.aff12.1D \
	-prefix ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf${ext} \
	${part_mag}

#	1d_tool.py -infile ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf.1D \
#		-demean -write ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf_demean.1D -overwrite
#	1d_tool.py -infile ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf_demean.1D \
#		-derivative -demean -write ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf_deriv1.1D -overwrite
#	1d_tool.py -infile ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf.1D \
# 		-derivative -collapse_cols euclidean_norm -write ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf_enorm.1D -overwrite

list_echoes=$( count -digits 1 1 4 )

for n_echo in $list_echoes
do

	part_mag=${origin}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}${ext}

	echo "3dAllineate -overwrite -base ${sbref_ln} -final cubic -1Dmatrix_apply ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf.aff12.1D -prefix ${output}/${subj}_ses-1_${task}_echo-${n_echoe}_part-mag_bold_${method}_mcf_al${ext} ${part_mag}"

	3dAllineate -overwrite -base ${sbref_ln} -final cubic \
		-1Dmatrix_apply ${output}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf.aff12.1D \
		-prefix ${output}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}_mcf_al${ext} \
		${part_mag} 

	
done
