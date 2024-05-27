#!/bin/bash


module load afni/stable
method=nordic
noise=3
# MAIN

#Check if output directory exists

list_subj=$( count -digits 1 1 5 )

#list_subj=$1
echo "List of subjects is ${list_subj}";

for n_sub in ${list_subj}

do
	for task in task-HABLA1200 task-HABLA1700
	do
		error_txt=/bcbl/home/public/MarcoMotion/logfiles/sub${n_sub}_${method}_${task}.txt

		if [[ -e ${error_txt} ]]; then

			rm ${error_txt}

		fi
		echo "bash /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_nordic.sh ${method} ${n_sub} ${noise} ${task} &> ${error_txt} &"

		bash /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_nordic.sh ${method} ${n_sub} ${noise} ${task} &> ${error_txt} &
	done
done
