
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/latest

method=hydra
preproc=func_preproc_${method}/
subj=sub-005
bids=/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/
repo=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}
origin=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/func/
output=/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/${preproc}
magnetization=10
noise=0



# MAIN
if [[ ! -e ${output} ]]; then

mkdir ${output}

fi

for task in task-HABLA1200 task-HABLA1700;do


volumes=$(3dinfo -nvi ${origin}${subj}_ses-1_${task}_echo-1_part-mag_bold.nii.gz)
echo "3dinfo -nvi ${origin}${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_dsd.nii.gz"

vol=$(($volumes-$noise))

echo "I have original ${volumes}  volumes but after removing noise we have: ${vol}"

for parts in part-mag part-phase
do

	list_echoes=$( count -digits 1 1 4 )

for n_echo in ${list_echoes}
do
	echo "Trimming subject ${subj} nifti ${origin}${subj}_ses-1_${task}_echo-${n_echo}_${parts}_bold.nii.gz[${magnetization}..${vol}]"

	3dcalc -a ${origin}${subj}_ses-1_${task}_echo-${n_echo}_${parts}_bold.nii.gz[${magnetization}..${vol}] -expr 'a' -prefix ${output}${subj}_ses-1_${task}_echo-${n_echo}_${parts}_bold_${method}_dsd.nii.gz -overwrite




done

done

done
