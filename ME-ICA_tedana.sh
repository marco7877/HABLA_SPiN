#!/usr/bin/bash

python ME-ICA_tedana.py --bids_dir /bcbl/home/public/MarcoMotion/Habla_restingState/ --echoes 4 --TE "11 28 45 61" --output_dir ME-ICA_nordic/ --preproc_bold_ext bold_mcf_al --mask_ext acq-whead_mask --nordic True 
