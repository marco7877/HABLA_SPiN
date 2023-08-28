addpath(genpath("/bcbl/home/home_g-m/mflores/mytoolboxes/NORDIC_raw/"));
cd '/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN';
%bold_mag='targetsub-001_ses-1_task-HABLA1700_echo-3_part-mag_bold_dsd.nii.gz';
%bold_phase='targetsub-001_ses-1_task-HABLA1700_echo-3_part-phase_bold_dsd.nii.gz';
%fn_out='sub-001_ses-1_task-HABLA1700_echo-3_part-mag_bold_nordic';%
ARG.temporal_phase=1;
ARG.phase_filter_width=10;
ARG.save_add_info=1;
ARG.DIROUT='target';
NIFTI_NORDIC('bold_mag','bold_phase','fn_out',ARG);