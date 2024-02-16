#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash
module load afni/latest

method=nordic
repo="/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/"
target="/bcbl/home/public/MarcoMotion/Habla_restingState/results_02-24_OC/"
subj=sub-002

mkdir -p ${target}


origin="/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/func_preproc_ME/"
for method in ME nordic hydra
do
	root="/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/func_preproc_${method}/"

	#TODO: remember that you need to add underneath the other task. this is for debugging
	for task in  task-HABLA1700
	do
		for descomposition in desc-optcom desc-optcomDenoised
		do

			echo analizing subject ${subj}
			echo analizing task ${task}

			mask=${origin}${subj}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz
			ln_mask=${root}${subj}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz
			#OPTIMAL COMBINATION TSNR CALCULATION
			3dTstat -mean -prefix  ${root}${task}/${descomposition}_bold_mean.nii.gz ${root}${task}/${descomposition}_bold.nii.gz -overwrite


			3dTproject -polort 5 -prefix  ${root}${task}/${descomposition}_bold_dt.nii.gz -input ${root}${task}/${descomposition}_bold.nii.gz -overwrite


			3dcalc -a ${root}${task}/${descomposition}_bold_dt.nii.gz -b ${root}${task}/${descomposition}_bold_mean.nii.gz -expr 'a+b' -prefix ${root}${task}/${descomposition}_bold_dt.nii.gz -overwrite


			3dTstat -stdevNOD -prefix  ${root}${task}/${descomposition}_bold_std.nii.gz ${root}${task}/${descomposition}_bold_dt.nii.gz -overwrite


			3dcalc -a ${root}${task}/${descomposition}_bold_mean.nii.gz -b ${root}${task}/${descomposition}_bold_std.nii.gz -m ${mask} -expr 'm*(a/b)' -prefix ${root}${task}/${descomposition}_bold_tsnr_${method}.nii.gz -overwrite


			ln -s ${root}${task}/${descomposition}_bold_tsnr_${method}.nii.gz ${target}${subj}_${task}${descomposition}_bold_tsnr_${method}.nii.gz


			ln -s ${mask} ${ln_mask}
			echo TSNR calculation done for ${tasks} with ${method} method

		done

	done
done
