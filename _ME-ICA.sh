#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash
#$ -o /bcbl/home/home_g-m/mflores/ips_logs
#$ -e /bcbl/home/home_g-m/mflores/ips_errors


module load afni/stable
module load python/venv


source activate /bcbl/home/home_g-m/mflores/conda_envs/tedana

method=$1 # vanilla, nordic, hydra 
n_subj=$2
task=$3
preproc=func_preproc_${method}

# define folders
subj=sub-00${n_subj}
input=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
origin=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/func_preproc_vanilla

nechoes=4

# MAIN

#Check if output durectory exists

# Define echo times for each dataset 
if [[ $task == task-HABLA1200 ]]
then
	echo_times="11 28 45 61"
else
	echo_times="13 36 58 81"
fi

output=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}/tedana_${task}
if [[ ! -e ${output} ]]; then
	mkdir ${output}
fi

# Reference original volumes
part_mag=${input}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf_al.nii.gz
echo "My reference part_mag is: ${part_mag}"

# Define mask volume and create symbolic link
mask_source=${origin}/${subj}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz
mask_preproc=${input}/${subj}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz

if [[ ! -e $mask_preproc ]]; then
	ln -s $mask_source $mask_preproc
fi
echo "My reference mask is: ${mask_preproc}"

# make a list from 1 to 4 with 1 length digits
list_echoes=$( count -digits 1 2 4 )
echo "List of echoes is ${list_echoes}"

# generate string with filenames of echoes for tedana
for n_echo in ${list_echoes}
do
	mag=$part_mag" "${input}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}_mcf_al.nii.gz
	part_mag=$mag
done

echo "tedana -d ${mag} -e ${echo_times} --out-dir ${output} --mask ${mask_preproc} --overwrite"
tedana -d ${mag} -e ${echo_times} --out-dir ${output} --mask ${mask_preproc} --overwrite

