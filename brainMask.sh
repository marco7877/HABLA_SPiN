#!/usr/bin/bash
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash

module load python/python3.9
module load afni/stable

sub=$1
python /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/brainMask.py --bids_dir /bcbl/home/public/MarcoMotion/Habla_restingState --filt_pattern sub-00${sub} 
