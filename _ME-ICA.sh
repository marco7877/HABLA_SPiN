#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash
#$ -o /bcbl/home/home_g-m/mflores/ips_logs
#$ -e /bcbl/home/home_g-m/mflores/ips_errors


#module load afni/latest
module load python/venv


			echo "*************************************************************"
echo "activating module load python/venv"
			source activate /bcbl/home/home_g-m/mflores/conda_envs/tedana


method=$1
preproc=func_preproc_${method}
sub=$2
subj=sub-00${sub}
input=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
origin=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
echoes=4

# MAIN

#Check if output durectory exists


for task in task-HABLA1200 task-HABLA1700
do
	if [ $task == task-HABLA1200 ]
	then
		echo_times="11 28 45 61"
	elif [ $task == task-HABLA1700 ]
	then
		echo_times="13 36 58 81"
	fi
	echo "My echo times for $task} are ${echo_times}"
		output=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}/${task}
		if [[ ! -e ${output} ]]; then
			echo "*************************************************************"
			mkdir ${output}

		fi
		# Reference original volumnes
		part_mag=${input}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf_al.nii.gz

		echo "My reference part_mag is: ${part_mag}"

		mask=${origin}/${subj}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz

		echo "My reference mask is: ${mask}"
		# make a list from 1 to 4 with 1 length digits

		list_echoes=$( count -digits 1 1 4 )

		echo "List of echoes is ${list_echoes}"

		for n_echo in ${list_echoes}

		do

			mag=$part_mag" "${input}/${subj}_ses-1_${task}_echo-${n_echo}_part-mag_bold_${method}_mcf_al.nii.gz

			part_mag=$mag
		done

		tedana -d ${mag} -e ${echo_times} --out-dir ${output} --mask ${mask} --overwrite
done
