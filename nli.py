#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 20 15:23:25 2023

@author: mflores
"""

from nilearn import image
from nilearn import signal
from nilearn.masking import apply_mask
from nilearn.maskers import NiftiMasker
from scipy import stats
import numpy as np
import pandas as pd
import os
import argparse
from plotnine import  *
######
# debbug

bids_dir = "/bcbl/home/public/MarcoMotion/Habla_restingState/"
#bold_file = dir_file+"sub-001_task-HABLA1200_masked_epi_gm_ocDenoised.nii.gz"
#bold_tsnr_file = dir_file + "sub-001_task-HABLA1200_masked_epi_gm_ocDenoised_tsnr.nii.gz"
directories=["func_preproc_cipactli","ME-ICA__","ME-ICA_nordic"]
#directory="func_preproc_cipactli"
oc_extention="task-HABLA1200_masked_epi_gm_ocDenoised.nii.gz"
tsnr_extention="task-HABLA1200_masked_epi_gm_ocDenoised_tsnr.nii.gz"
###### Arguments ########################################################3###########
#parser=argparse.ArgumentParser(description="""Generates histograms from fmri 
#                              volumes""")
#parser.add_argument("--bids_dir", default=None, type=str,
#                    help="Full path to the BIDS directory")
#
#parser.add_argument("--directories", default=None, type=list,
#                    help="""List of subdirectories inside bids directory
#                    that will be considered as different factors to plot histograms""")
#
#parser.add_argument("--oc_extention", default=None, type=str,
#                    help="""Extention of the target OC file to be look upon
#                    i.e., if my target file has the name:
#                    sub-001_task-HABLA1200_masked_epi_gm_ocDenoised.nii.gz
#                    then, OC_extention=task-HABLA1200_masked_epi_gm_ocDenoised.nii.gz""")
#
#parser.add_argument("--tsnr_extention", default=None, type=str,
#                    help="""Extention of the target tsnr file to be look upon
#                    i.e., if my target file has the name:
#                    sub-001_task-HABLA1200_masked_epi_gm_ocDenoised_tsnr.nii.gz
#                    then, OC_extention=task-HABLA1200_masked_epi_gm_ocDenoised_tsnr.nii.gz""")

#parser.add_argument("--tsnr_extention", default=None, type=str,
#                    help="""Extention of the target tsnr file to be look upon
#                    i.e., if my target file has the name:
#                    sub-001_task-HABLA1200_masked_epi_gm_ocDenoised_tsnr.nii.gz
#                    then, OC_extention=task-HABLA1200_masked_epi_gm_ocDenoised_tsnr.nii.gz""")
###### Find files ###################################################################
tsnr_list=[]
source_oc_all=[]
source_tsnr_all=[]
preprocessing_method=[]
for directory in directories:
	print(directory)
	source_oc=sorted([os.path.join(root, x)
                   for root, dirs, files in os.walk(bids_dir)
                   for x in files if x.endswith(oc_extention)
                   if directory in root])
	source_tsnr=sorted([os.path.join(root, x)
                   for root, dirs, files in os.walk(bids_dir)
                   for x in files if x.endswith(tsnr_extention)
                   if directory in root])
	source_oc_all.extend(source_oc)
	source_tsnr_all.extend(source_tsnr)
	if directory == "func_preproc_cipactli":
		tmp_preprocessing_methods=["ME-ICA_HYDRA"]*len(source_oc)
	else:
		tmp_preprocessing_methods=[directory]*len(source_oc)
	preprocessing_method.extend(tmp_preprocessing_methods)	
######
# Reading dataset
data_oc_masked=[]
zdata_tsnr_masked=[]
pctdata_tsnr_masked=[]
for i in range (len(source_oc_all)):
    number=source_oc_all[i].split("sub-00")
    subj=number[1][0]
    bold_file=source_oc_all[i]
    bold_tsnr_file=source_tsnr_all[i]
    oc_denoised = image.load_img(bold_file)
    tsnr=image.load_img(bold_tsnr_file)
#	tsnr=tsnr.slicer[:,:,:,0]#we only need one slice, because they are all ==

######
# creating  empty data frame per subject


######
# masking dataset
# data is masked, background = 0
    masker_oc = NiftiMasker(mask_strategy="background", verbose=1)
    masker_oc.fit(bold_file)
    masked_oc = masker_oc.fit_transform(oc_denoised)  # apply mask?
    masker_tsnr = NiftiMasker(mask_strategy="background", verbose=1)
    masker_tsnr.fit(bold_tsnr_file)
    masked_tsnr = masker_tsnr.fit_transform(tsnr)  # apply mask?
    masked_tsnr=masked_tsnr.squeeze()#converting 1*n array into n,

######
# cleaning dataset
#convert to Z-scores
#--timeseries-- z-score per voxel for timeseries
    oc_clean = signal.clean(masked_oc, detrend=False,
                          standardize="zscore_sample")
#--overall-- z-score per distribution of values among UNIQUE volume
    tsnr_clean = stats.zscore(masked_tsnr,axis=None)

#mask values that are further that  1.5 std from mean
    oc_cleanmask = np.ma.masked_greater(np.absolute(oc_clean), 1.5)
    tsnr_cleanmask = np.ma.masked_greater(np.absolute(tsnr_clean), 1.5)

#applying z-informed mask over subj data
    zmasked_oc = np.ma.masked_array(masked_oc, oc_cleanmask.mask)
    zmasked_tsnr = np.ma.masked_array(masked_tsnr, tsnr_cleanmask.mask)

#generating pct z-informed masked values over time volumes
    pct_masked_oc=np.ma.count_masked(zmasked_oc,axis=0)/len(zmasked_oc)
    pct_masked_tsnr=np.ma.count_masked(zmasked_tsnr)/len(zmasked_tsnr)

#calculating mean signal value per voxel over time
#NOTE: mean is extracted to follow the normality assumption after
#      z-transformation of the values
#      --tsnr does not follow this, because is not a volume through time
    mean_masked_oc=np.mean(zmasked_oc,axis=0)

#replacing masked values with nan 
    mean_masked_oc=mean_masked_oc.filled(np.NaN)
    zmasked_tsnr=zmasked_tsnr.filled(np.NaN)
	

######
#adding column with id repeated = voxels
# TODO: This is extremily unefficient, must find a way to use list of lists instead of
# numpy arrays. I will ask Ry about this

    if len(pct_masked_oc) != len(mean_masked_oc):
        raise ValueError(f"""dimentions of voxels do not match!""")
    tmp_data_oc_masked=np.column_stack((mean_masked_oc,pct_masked_oc,
                             np.repeat(subj,(len(mean_masked_oc))))).tolist()
    tmp_zdata_tsnr_masked=np.column_stack((zmasked_tsnr,
                                  np.repeat(subj,(len(zmasked_tsnr))))).tolist()
    tmp_pctdata_tsnr_masked=np.array([pct_masked_tsnr,subj]).tolist()
    for sublist in tmp_data_oc_masked:
        sublist.append(preprocessing_method[i])
    for sublist in tmp_zdata_tsnr_masked:
        sublist.append(preprocessing_method[i])
    tmp_pctdata_tsnr_masked.append(preprocessing_method[i])
    data_oc_masked.extend(tmp_data_oc_masked)
    zdata_tsnr_masked.extend(tmp_zdata_tsnr_masked)
    pctdata_tsnr_masked.append(tmp_pctdata_tsnr_masked)
################################################
# Example of how to plot basic histogramfrom data
# I am using variable as  a 1-D vector
# Do not run
# df=pd.DataFrame(data=variable, columns=['var_name'])
# plotnine_obj=ggplot(df,aes(x='var_name'))+geom_histogram()
# plotnine_obj.draw() #plot inline
# plotnine_obj.save(filename='dir/dir/img.png',dpi=300)
df_oc_masked=pd.DataFrame(data=data_oc_masked, columns=["value","prop","ID","method"])
df_oc_masked['value']=pd.to_numeric(df_oc_masked['value'], errors='coerce')
df_oc_masked_plot=df_oc_masked.dropna()
df_tsnr=pd.DataFrame(data=zdata_tsnr_masked, columns=["value","ID","method"])
df_tsnr['value']=pd.to_numeric(df_tsnr['value'], errors='coerce')
df_tsnr_plot=df_tsnr.dropna()

df_oc_masked_plot.to_csv(bids_dir+"OC_dataframe_GM_group.csv",index=False)
df_tsnr_plot.to_csv(bids_dir+"tsnr_dataframe_GM_group.csv",index=False)

####
plotnine_oc=(ggplot(df_oc_masked_plot,aes(x="method",y="value",fill="ID"))+geom_boxplot())
#plotnine_oc.draw()
plotnine_oc.save(bids_dir+"oc_masked_GM_group.png", verbose=False)

## plot 2
plotnine_tsnr=(ggplot(df_tsnr_plot,aes(x="method",y="value",fill="ID"))+geom_boxplot())
#plotnine_tsnr.draw()
plotnine_tsnr.save(bids_dir+"tsnr_masked_GM_group.png", verbose=False)


######
# creating subject's dataframes 
