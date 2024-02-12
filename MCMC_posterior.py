#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov  6 14:45:06 2023

@author: mflores
"""
###### Libraries
#import theano
import pymc as pm
import pandas as pd
import numpy as np

oc_file="/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/OC_dataframe_GM_group.csv"
tsnr_file="/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/OC_dataframe_GM_group.csv"
method_list=["func_preproc_cipactli", "ME-ICA__","ME-ICA_nordic"]
###### reading csv to load data
oc=pd.read_csv(oc_file)
tsnr=pd.read_csv(tsnr_file)
oc_result=[]
tsnr_result=[]
for i in range(3):
    method=method_list[i]
    tmp_oc=oc[oc["method"]==method]
    tmp_tsnr=tsnr[tsnr["method"]==method]
    mu_oc=np.mean(tmp_oc["value"])
    sigma_oc=np.std(tmp_oc["value"])
    mu_tsnr=np.mean(tmp_tsnr["value"])
    sigma_tsnr=np.std(tmp_tsnr["value"])
    with pm.Model() as model:
        mu=pm.Beta('mu',alpha=1,beta=2)
        sigma=pm.Uniform('sigma',lower=-1,upper=20)
        y=pm.Beta('y',mu=mu,sigma=sigma,observed=tmp_oc["value"])
        trace=pm.sample(2000, tune=2000, chains=4)
        
        
        