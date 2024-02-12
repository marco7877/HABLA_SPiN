
#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load afni/latest

method=nordic
preproc=func_preproc_${method}/
sub=001
bids="/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/"
repo="/bcbl/home/public/MarcoMotion/Habla_restingState/subj-"${sub}
origin="/bcbl/home/public/MarcoMotion/Habla_restingState/sub-00${sub}/ses-1/func/"
output="/bcbl/home/public/MarcoMotion/Habla_restingState/sub-00${sub}/ses-1/${preproc}"
magnetization=10
noise=0



# MAIN

for task in task-HABLA1200 task-HABLA1700;do
volumes=3dinfo -nt sub-${sub}_ses-1_${task}_echo-1_part-mag_bold.nii.gz
vol=$(($volumes-$noise))
echo ${vol}
for parts in part-mag part-phase;do
for n_echo in {1..4};do
#for oc in desc-optcom desc-optcomDenoised;do

echo Trimming subject sub-00${sub}





echo -a '${origin}sub-${sub}_ses-1_${task}_echo-${n_echo}_${parts}_bold.nii.gz[${noise}..${vol}]' ${root}${task}brain_mask/${oc}_bold_mean.nii.gz -expr 'a+b' -prefix ${root}${task}brain_mask/${oc}_bold_dt.nii.gz -overwrite




done
done
done
