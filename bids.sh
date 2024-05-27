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


#list_subj=( "08" "09" "10" "11" "12" )

echo "List of subjects is ${list_subj}" 

for n_sub in 05 06 08 09 10 11 12

do
	error_txt=/bcbl/home/home_g-m/mflores/ips_logs/sub${n_sub}_bids.txt

	if [[ -e ${error_txt} ]]; then

		rm ${error_txt}

	fi
	if [[ ${ips}  == True ]]; then


		qsub -q short.q -N sub${n_sub}_${method}_${task}_tsnr -o ${error_txt} -e ${error_txt} /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_fmwh.sh ${method} ${n_sub} ${task}
	else
		echo " bidscoiner -f /bcbl/home/public/MarcoMotion/4Marco /bcbl/home/public/MarcoMotion/HABLA2 -p ${n_sub} &> ${error_txt}"

		bash /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/_bids.sh  ${n_sub} &> ${error_txt} &
	fi
done
