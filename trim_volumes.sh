#!/usr/bin/bash
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash
module load python/python3.6
module load afni/latest

python /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/trim_volumes.py --bids_dir /bcbl/home/public/MarcoMotion/Habla_restingState/sub-003 --echoes 4  --filt_pattern func/  --excl_noise "False" --drop_noise 0 --output_extention _nordic_dsd.nii.gz --output_dir func_preproc_nordic/
