#!/bin/bash


module load afni/stable
# MAIN

#Check if output durectory exists




list_subj=$( count -digits 1 1 5 )

echo "List of subjects is ${list_subj}";


for n_sub in ${list_subj}

do
	error_txt=/bcbl/home/home_g-m/mflores/ips_logs/sub${n_sub}_brainMask.txt

	if [[ -e ${error_txt} ]]; then

		rm ${error_txt}

	fi
	bash /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/brainMask.sh ${n_sub} &> ${error_txt} &
done
