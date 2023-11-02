#!/bin/bash
for i in $(seq 1 5);
do
	3dUnifize -input /bcbl/home/public/MarcoMotion/Habla_restingState/sub-00${i}/ses-1/anat/sub-00${i}_ses-1_acq-uniclean_T1w.nii.gz -prefix /bcbl/home/public/MarcoMotion/Habla_restingState/sub-00${i}/ses-1/anat/sub-00${i}_ses-1_acq-uniclean_T1w.nii.gz -overwrite
done

