addpath(genpath("/bcbl/home/home_g-m/mflores/mytoolboxes/NORDIC_raw/"));
cd '/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/';
ARG.temporal_phase=1;
ARG.phase_filter_width=10;
ARG.save_add_info=1;
ARG.DIROUT='target';
NIFTI_NORDIC('bold_mag','bold_phase','fn_out',ARG);
