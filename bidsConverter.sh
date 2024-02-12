#!/bin/bash
#$ -m be
#$ -M mflores@bcbl.eu
#$ -S /bin/bash
#$ 

module load afni/latest
module load python/venv

echo "You are inside your cluster, we are charging target environment"
source activate /bcbl/home/home_g-m/mflores/conda_envs/bidscoin_4.0


#projectName= HABLA_REST #The name of your project as exported in raw, i.e. HABLA_REST_005
#sessionName= CRANEO_FUNCIONAL #The name of the session where we are lookin for data, i.e. CRANEO_FUNCIONAL-1
# Now we are running bids
echo "You are telling BIDSmapper how to name your data"
# First we are going to call bidsmapper. note: only necesary to run the first time
# This is going to call a GUI where you should manually state the name for the nii.gz output file
#bidsmapper -n "$projectName" -m "$sessionName" $workingDirectory$DICOM_sourceDirectory $workingDirectory$BIDS_outputDirectory 
echo "Now you are converting your DICOM to BIDS format "
bidscoiner -f /bcbl/home/public/MarcoMotion/4Marco/ /bcbl/home/public/MarcoMotion/Habla_restingState/ -p HABLA_REST_005 

