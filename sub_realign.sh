#!/bin/bash
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash



method=hydra
me=true
# MAIN

#Check if output durectory exists




list_subj=$( count -digits 1 1 5 )

echo "List of echoes is ${list_subj}"

for n_sub in ${list_subj}

do
	error_txt=/bcbl/home/home_g-m/mflores/ips_logs/sub${n_sub}_${method}_realign.txt

	if [[ -e ${error_txt} ]]; then

		rm ${error_txt}

	fi
	qsub -q short.q -N sub${n_sub}_${method}_realign -o ${error_txt} -e ${error_txt} /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_realign.sh ${method} ${n_sub} ${me}
done
