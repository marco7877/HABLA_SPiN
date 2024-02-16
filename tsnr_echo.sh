#$ -m be
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash
module load afni/latest

method=nordic
repo="/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/"
target="/bcbl/home/public/MarcoMotion/Habla_restingState/results_02-24/"
subj=sub-002

mkdir -p ${target}


origin="/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/func_preproc_ME/"
for method in ME nordic hydra
do
	root="/bcbl/home/public/MarcoMotion/Habla_restingState/${subj}/ses-1/func_preproc_${method}/"

	#TODO: remember that you need to add underneath the other task. this is for debugging
	for task in  task-HABLA1700
	do

		list_echoes=$( count -digits 1 2 3 )
		for echo_n in list_echoes 
		do

			echo analizing subject ${subj}
			echo analizing task ${task}

			part_mag=${root}/${subj}_ses-1_${task}_echo-1_part-mag_bold_${method}_mcf_al

			echo "My reference part_mag is: ${part_mag}"
			mask=${origin}${subj}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz
			ln_mask=${root}${subj}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz
			#OPTIMAL COMBINATION TSNR CALCULATION
			3dTstat -mean -prefix  ${part_mag}_mean.nii.gz ${part_mag}.nii.gz -overwrite


			3dTproject -polort 5 -prefix  ${part_mag}_dt.nii.gz -input ${part_mag}.nii.gz -overwrite


			3dcalc -a ${part_mag}_dt.nii.gz -b ${part_mag}_mean.nii.gz -expr 'a+b' -prefix ${part_mag}_dt.nii.gz -overwrite


			3dTstat -stdevNOD -prefix  ${part_mag}_std.nii.gz ${part_mag}_dt.nii.gz -overwrite


			3dcalc -a ${part_mag}_mean.nii.gz -b ${part_mag}_std.nii.gz -m ${mask} -expr 'm*(a/b)' -prefix ${part_mag}_tsnr_${method}.nii.gz -overwrite


			ln -s ${part_mag}_tsnr_${method}.nii.gz ${part_mag}_tsnr_${method}.nii.gz


			ln -s ${mask} ${ln_mask}
			echo TSNR calculation done for ${tasks} with ${method} method

		done

	done
done
