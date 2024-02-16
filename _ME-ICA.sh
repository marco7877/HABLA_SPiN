#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash
#$ -o /bcbl/home/home_g-m/mflores/ips_logs
#$ -e /bcbl/home/home_g-m/mflores/ips_errors


#module load afni/latest
module load python/venv


source activate /bcbl/home/home_g-m/mflores/conda_envs/tedana


method=ME
preproc=func_preproc_${method}
subj=sub-002
input=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
origin=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/func_preproc_ME
echoes=4
echo_times="13 36 58 81"
task=task-HABLA1700

# MAIN

#Check if output durectory exists

if [[ ! -e ${output} ]]; then

	mkdir ${output}

fi


# Reference original volumnes
part_mag=${input}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf_al.nii.gz

echo "My reference part_mag is: ${part_mag}"

mask=${origin}/${subj}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz

echo "My reference mask is: ${mask}"
# make a list from 1 to 4 with 1 length digits

list_echoes=$( count -digits 1 2 4 )

echo "List of echoes is ${list_echoes}"

for n_echo in ${list_echoes}

do

	mag=$part_mag" "${input}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}_mcf_al.nii.gz

	part_mag=$mag
done

tedana -d ${mag} -e ${echo_times} --out-dir ${input} --mask ${mask} --overwrite
