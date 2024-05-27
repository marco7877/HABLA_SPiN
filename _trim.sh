
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/stable

method=$1 # vanilla, nordic, hydra 
preproc=func_preproc_${method} # better without the  
sub=$2
subj=sub-00${sub}
task=${4}
run=${5}
# define folders
bids=/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/
repo=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}
origin=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/func/
output=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}

trimvol=10 # number of volumes to trim due to steaty state magnetization

noise=$3 # number of noise volumes

nechoes=4

# MAIN
if [[ ! -e ${output} ]]; then

	mkdir ${output}

fi

for parts in part-mag part-phase
do

	list_echoes=$( count -digits 1 1 4 )

	for n_echo in ${list_echoes}
	do
		echo "Trimming subject ${subj} nifti ${origin}${subj}_ses-1_${task}_echo-${n_echo}_${parts}_bold.nii.gz[${trimvol}..${vol}]"

		3dcalc -a "${origin}${subj}_ses-1_${task}_echo-${n_echo}_${parts}_bold.nii.gz[${trimvol}..$]" -expr 'a' \
			-prefix "${output}/${subj}_ses-1_${task}_echo-${n_echo}_${parts}_bold_${method}_dsd.nii.gz" -overwrite

		if [[ "${method}" == "vanilla" ]]
		then

			echo "3dinfo -nvi ${output}/${subj}_ses-1_${task}_echo-${n_echo}_${parts}_bold_${method}_dsd.nii.gz"

			volumes=$(3dinfo -nvi ${output}/${subj}_ses-1_${task}_echo-${n_echo}_${parts}_bold_${method}_dsd.nii.gz)

			vol=$(($volumes-$noise))

			echo "Original data ${volumes} volumes, but after removing noise volumes it has ${vol} volumes"
			3dcalc -a "${output}/${subj}_ses-1_${task}_echo-${n_echo}_${parts}_bold_${method}_dsd.nii.gz[0..${vol}]" -expr 'a' \
				-prefix "${output}/${subj}_ses-1_${task}_echo-${n_echo}_${parts}_bold_${method}.nii.gz" -overwrite
		fi

	done
done


