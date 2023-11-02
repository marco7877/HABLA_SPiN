#!/bin/bash
# flags for the cluster to send us begin, end and error messages
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash
PRJDIR=/bcbl/home/public/MarcoMotion/Habla_restingState
subj=sub-005
# run Freesurfer recon-all to separate white matter from gray one. For this we are using both the T1 and the T2
# TODO study Freesurfer
#recon-all -i ${PRJDIR}/${subj}/ses-1/anat/${subj}_ses-1_acq-uniclean_T1w.nii.gz -T2 ${PRJDIR}/${subj}/ses-1/anat/${subj}_ses-1_T2w.nii.gz -3T -all -s ${subj} -sd ${PRJDIR}/freesurfer
# Import Freesurfer results into SUMA-land 
# TODO study SUMA
@SUMA_Make_Spec_FS -fs_setup -NIFTI -sid ${subj} -fspath ${PRJDIR}/freesurfer/${subj}

