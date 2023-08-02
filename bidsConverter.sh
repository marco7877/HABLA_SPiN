#!/bin/bash

# This is thought to run on cajal, if you haver a custom script to access cajal write it below, if not
# acces your target cluster before running this script
/bcbl/home/home_g-m/mflores/cajal.sh
# Bids converter is located within a conda repository. build the aforementioned if where you run this
echo "You are inside your cluster, we are charging target environment"
source activate bidscoin_4.0
DICOM_sourceDirectory= ${workingDirectory}/4Marco/
BIDS_outputDirectory= ${workingDirectory}/Habla_restingState/
projectName= HABLA_REST #The name of your project as exported in raw, i.e. HABLA_REST_001
sessionName= CRANEO_FUNCIONAL #The name of the session where we are lookin for data, i.e. CRANEO_FUNCIONAL-1
# Now we are running bids
echo "You are telling BIDSmapper how to name your data"
# First we are going to call bidsmapper. note: only necesary to run the first time
# This is going to call a GUI where you should manually state the name for the nii.gz output file
bidsmapper -n "$projectName" -m "$sessionName" $workingDirectory$DICOM_sourceDirectory $workingDirectory$BIDS_outputDirectory 
echo "Now you are converting your DICOM to BIDS format "
bidscoiner $workingDirectory$DICOM_sourceDirectory $workingDirectory$BIDS_outputDirectory 

