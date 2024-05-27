#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash



# MAIN

#Check if output durectory exists

noise_volumes=3


list_subj=$( count -digits 1 1 5 )

echo "List of subjects is ${list_subj}"
for method in snake
do

for n_sub in ${list_subj}

do
		for task in task-HABLA1200 task-HABLA1700
		do
	error_txt=/bcbl/home/public/MarcoMotion/logfiles/sub${n_sub}_${method}_${task}_trim.txt

	if [[ -e ${error_txt} ]]; then

		rm ${error_txt}

	fi
	qsub -q short.q -N sub${n_sub}_${method}_${task}_trim -o ${error_txt} -e ${error_txt} /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_trim.sh ${method} ${n_sub} ${noise_volumes} ${task}
done
done
done
