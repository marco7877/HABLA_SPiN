#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash


module load afni/stable
# MAIN

#Check if output durectory exists




list_subj=$( count -digits 1 1 5 )

echo "List of subjects is ${list_subj}" 

for method in hydra
do
	for n_sub in ${list_subj}

	do
		for task in task-HABLA1200 task-HABLA1700
		do
			error_txt=/bcbl/home/home_g-m/mflores/ips_logs/sub${n_sub}_${method}_${task}_OC.txt

			if [[ -e ${error_txt} ]]; then

				rm ${error_txt}

			fi
			echo "bash /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_ME-ICA.sh ${method} ${n_sub} ${task} &> ${error_txt}"
			bash /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_ME-ICA.sh ${method} ${n_sub} ${task} &> ${error_txt} &
		done
	done
done
