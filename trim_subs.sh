#!/bin/bash



method=nordic
# MAIN

#Check if output durectory exists


noise_volumes=3


#list_subj=$( count -digits 1 1 5 )

list_subj=(06 08 09 10 11 12 )
list_run=(1 2)
echo "List of subjects is ${list_subj}"

for method in nordic
do

for n_sub in ${list_subj}

do
		for task in task-WORD task-SENT task-SYLAB
		do

for run in ${list_run}
do
	error_txt=/bcbl/home/home_g-m/mflores/ips_logs/sub${n_sub}_${method}_${task}_${ses}_trim.txt

	if [[ -e ${error_txt} ]]; then

		rm ${error_txt}

	fi
	bash /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_trim.sh ${method} ${n_sub} ${noise_volumes} ${task} ${run} &> ${error_txt} &
done
done
done
done
