#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash


module load afni/stable
# MAIN

#read -p 'Run in IPS? True or enter to skip' ips

#Check if argument is given
ips=${1:-False}


list_subj=$( count -digits 1 1 5 )

	echo "List of subjects is ${list_subj}" 

	for method in "vanilla" "nordic" "hydra"
	do
	for n_sub in ${list_subj}

	do
	for task in task-HABLA1200 task-HABLA1700
	do
	error_txt=/bcbl/home/home_g-m/mflores/ips_logs/sub${n_sub}_${method}_${task}_tsnr.txt

	if [[ -e ${error_txt} ]]; then

	rm ${error_txt}

	fi
	if [[ ${ips}  == True ]]; then


	qsub -q short.q -N sub${n_sub}_${method}_${task}_tsnr -o ${error_txt} -e ${error_txt} /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_fmwh.sh ${method} ${n_sub} ${task}
	else
	echo "bash /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_methods_tsnr.sh ${method} ${n_sub} ${_task} &> ${error_txt}"

	bash /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/methods_tsnr.sh ${method} ${n_sub} ${task} &> ${error_txt} &
	fi
	done
	done
	done
