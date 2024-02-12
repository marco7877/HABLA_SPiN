#!/usr/bin/bash
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash



module load python/python3.9
module load afni/latest
module load python/venv
module load matlab/R2022B



#how to run hydra
sub='sub-005'
noise=0
root="/bcbl/home/public/MarcoMotion/Habla_restingState/${sub}/ses-1/"
repo="/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/"
tsnr_echo=(2 3)
task="task-HABLA1700"
te="13 36 58 81"
nordic_file=nordic3.m

echo  "/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/hydra.py --echo1 ${root}func_preproc/${sub}_ses-1_${task}_echo-1_part-mag_bold_nordic_dsd.nii.gz --source_sbref ${root}func/${sub}_ses-1_${task}_echo-1_part-mag_sbref.nii.gz --echoes 4 --TE "11 28 45 61" --mask ${root}func_preproc/${sub}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz --matlab_nordic nordic.m --filt_pattern ${task}"

source activate /bcbl/home/home_g-m/mflores/conda_envs/tedana
python /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/cipactli.py --echo1 ${root}func_preproc_hydra/${sub}_ses-1_${task}_echo-1_part-mag_bold_hydra_dsd.nii.gz --source_sbref ${root}func/${sub}_ses-1_${task}_echo-1_part-mag_sbref.nii.gz --echoes 4 --TE "13 36 58 81"  --mask ${root}func_preproc/${sub}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz --matlab_nordic ${nordic_file} --filt_pattern ${task} --output_dir func_preproc_hydra/ --noise_volumes ${noise}


#echo "Calculating tsnr from source echo-1 and echo-2"

#for echo in ${tsnr_echo}
#do
#/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/tsnr.sh ${id} ${root}func_preproc_hydra/${sub}_ses-1_${task}_echo-${echo}_part-mag_bold_hydra_mcf_al.nii.gz ${root}func_preproc/${sub}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz brain
#done

#echo "Calculating tsnr for ME-ICA optimal combination"

#/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/tsnr.sh ${id} ${root}func_preproc_hydra/${task}brain_mask/desc-optcom_bold.nii.gz ${root}func_preproc/${sub}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz brain

#echo "Calculating tsnr for ME-ICA optimal combination - rejected components (denoised)"

#/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/tsnr.sh ${id} ${root}func_preproc_hydra/${task}brain_mask/desc-optcomDenoised_bold.nii.gz ${root}func_preproc/${sub}_ses-1_${task}_echo-1_part-mag_brain_mask.nii.gz brain

#echo "Calculating %difference in S0 and T2* maps"

#/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/nordicNoise.sh ${root}func_preproc_hydra/${task}brain_mask/T2starmap.nii.gz   ${root}ME-ICA/${task}brain_mask/T2starmap.nii.gz False

#/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/nordicNoise.sh ${root}func_preproc_hydra/${task}brain_mask/S0map.nii.gz   ${root}ME-ICA/${task}brain_mask/S0map.nii.gz False

#echo "Calculating thermal noise maps"
#for echo in ${tsnr_echo}
#do
#/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/nordicNoise.sh ${root}func_preproc/${sub}_ses-1_${task}_echo-${echo}_part-mag_bold_mcf_al.nii.gz  ${root}func_preproc_hydra/${sub}_ses-1_${task}_echo-${echo}_part-mag_bold_hydra_mcf_al.nii.gz true
#done
