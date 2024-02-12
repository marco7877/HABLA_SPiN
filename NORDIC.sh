#!/usr/bin/bash
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash
module load python/python3.9
module load afni/latest
module load matlab/R2022B


python /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/Nordic.py --bids_dir /bcbl/home/public/MarcoMotion/Habla_restingState --matlab_nordic /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/nordic.m --filt_pattern "sub-001" --ext_phase  _part-phase_bold_nordic_dsd.nii.gz --ext_mag  _part-mag_bold_nordic_dsd.nii.gz  --output_dir func_preproc_nordic/
