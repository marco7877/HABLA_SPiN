#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/stable

method=nordic
# MAIN

#Check if output durectory exists




list_subj=$( count -digits 1 1 5 )

	echo "List of echoes is ${list_subj}"

	for n_sub in ${list_subj}

	do
	for task in task-HABLA1200 task-HABLA1700
	do
	error_txt=/bcbl/home/home_g-m/mflores/ips_logs/sub${n_sub}_${method}_${task}_realign.txt

	if [[ -e ${error_txt} ]]; then

	rm ${error_txt}

	fi
	qsub -q short.q -N sub${n_sub}_${method}_${task}_realign -o ${error_txt} -e ${error_txt} /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_realign.sh ${method} ${n_sub} ${task}
	done
	done
