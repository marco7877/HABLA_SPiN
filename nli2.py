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

bids_dir = "/bcbl/home/public/MarcoMotion/Habla_restingState/OHBM_analysis3/"
directories=["func_preproc_cipactli","ME-ICA__","ME-ICA_nordic"]
task="HABLA1200"
tsnr_class="denoised"
tsnr_extention="task-"+task+"desc-optcomDenoised_bold_tsnr_"
ext=".nii.gz"
methods=["hydra", "nordic","tedana"]
labels=["Hydra+OC", "Nordic+OC","OC"]
voxel="2.4*2.4*2.4mm"
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
#source_oc_all=[]
source_tsnr_all=[]
preprocessing_method=[]
for i in range(len(methods)):
	source_tsnr=sorted([file_
                   for file_ in os.listdir(bids_dir)
                   if file_.endswith(tsnr_extention+methods[i]+ext)])
	source_tsnr_all.extend(source_tsnr)
	tmp_preprocessing_methods=[labels[i]]*len(source_tsnr)
	preprocessing_method.extend(tmp_preprocessing_methods)	
######
# Reading dataset
tsnr_masked=[]
for i in range (len(source_tsnr_all)):
    number=source_tsnr_all[i].split("sub-00")
    subj=number[1][0]
    bold_tsnr_file=source_tsnr_all[i]
    tsnr=image.load_img(bids_dir+bold_tsnr_file)
#	tsnr=tsnr.slicer[:,:,:,0]#we only need one slice, because they are all ==

######
# creating  empty data frame per subject


######
# masking dataset
# data is masked, background = 0
    masker_tsnr = NiftiMasker(mask_strategy="background", verbose=1)
    masker_tsnr.fit(bids_dir+bold_tsnr_file)
    masked_tsnr = masker_tsnr.fit_transform(tsnr)  # apply mask?
    masked_tsnr=masked_tsnr.squeeze()#converting 1*n array into n,
    tmp_tsnr_masked=np.column_stack((masked_tsnr,
                                  np.repeat(subj,(len(masked_tsnr))))).tolist()
    for sublist in tmp_tsnr_masked:
        sublist.append(preprocessing_method[i])
    tsnr_masked.extend(tmp_tsnr_masked)
################################################
# Example of how to plot basic histogramfrom data
# I am using variable as  a 1-D vector
# Do not run
# df=pd.DataFrame(data=variable, columns=['var_name'])
# plotnine_obj=ggplot(df,aes(x='var_name'))+geom_histogram()
# plotnine_obj.draw() #plot inline
# plotnine_obj.save(filename='dir/dir/img.png',dpi=300)
df_tsnr=pd.DataFrame(data=tsnr_masked, columns=["value","ID","method"])
df_tsnr['value']=pd.to_numeric(df_tsnr['value'], errors='coerce')
df_tsnr_plot=df_tsnr.dropna()

df_tsnr_plot.to_csv(bids_dir+task+tsnr_class+"tsnr_dataframe_group.csv",index=False)


## plot 2
plotnine_tsnr=(ggplot(df_tsnr_plot,aes(x="method",y="value",fill="ID"))+geom_boxplot()
               +xlab(voxel)+ylab("TSNR value"))
plotnine_tsnr.draw()
plotnine_tsnr.save(bids_dir+task+tsnr_class+"tsnr_masked_group.png", verbose=False)


######
# creating subject's dataframes 
