#!/bin/bash


module load afni/stable
# MAIN

#Check if output durectory exists




list_subj=$( count -digits 1 1 5 )

echo "List of echoes is ${list_subj}" &


for method in hydra
do
for n_sub in ${list_subj}

do
	for task in task-HABLA1700 task-HABLA1200
	do
	error_txt=/bcbl/home/home_g-m/mflores/ips_logs/sub${n_sub}_${method}_${task}_realign.txt

	if [[ -e ${error_txt} ]]; then

		rm ${error_txt}

	fi
	bash /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_realign.sh ${method} ${n_sub} ${task} &> ${error_txt} &
done
done
done
