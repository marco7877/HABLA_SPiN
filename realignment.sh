#!/usr/bin/bash
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash



module load python/python3.9
module load afni/latest


python /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/realignment.py #--bids_dir "/bcbl/home/public/MarcoMotion/Habla_restingState/" --echoes 4 --output_dir "func_preproc_cipactli/" --nordic Nordic --filt_pattern "sub-001" --dir_pattern "func/" --noise_volumes 3 --bold_mag_ext "_part-mag_bold_nordic" --dir_preproc_pattern "func_preproc_cipactli/" --align_matrix_ext "_nordic_mcf.aff12.1D"
