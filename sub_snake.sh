#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/stable

method=snake
noise=12

# MAIN

#Check if output durectory exists




list_subj=$( count -digits 1 1 5 )

echo "List of subjects is ${list_subj}"

for n_sub in ${list_subj}

do
	for task in task-HABLA1700 task-HABLA1200
	do
	error_txt=/bcbl/home/public/MarcoMotion/logfiles/sub${n_sub}_${method}_${task}_snake.txt

	if [[ -e ${error_txt} ]]; then

		rm ${error_txt}

	fi
	qsub -q short.q -N sub${n_sub}_${method}Nordic_${task} -o ${error_txt} -e ${error_txt} /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_snake.sh ${method} ${n_sub} ${noise} ${task}

done
done
