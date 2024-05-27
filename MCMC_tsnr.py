#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 12 11:55:11 2024

@author: mflores
"""
#libraries

import pandas as pd
import numpy as np
import pymc as pm
import arviz as az
import matplotlib.pyplot as plt
from scipy import stats as st
# MAIN


#Min Max normalization function
def minmax(dataframe,column):
    return (dataframe[column]-dataframe[column].min())/(dataframe[column].max()-
            dataframe[column].min())

def AlphaBeta(mu,sigma):
    parameters=[]
    alpha=(mu**2)*((1-mu)/sigma** 2 - 1 / mu)
    
    beta=alpha * (1/ mu - 1)
    parameters.append(alpha)
    parameters.append(beta)
    return parameters

    #reading data
directory="/bcbl/home/public/MarcoMotion/Habla_restingState/analysis_03-24_/"
my_files=["HABLA1200echo2_fwhm_tsnr_dataframe_group.csv","HABLA1700echo2_fwhm_tsnr_dataframe_group.csv"]
mcmc_sample=500
np.random.seed(7877)
for file in my_files:

    #file="HABLA1200OCdenoisedtsnr_dataframe_group.csv"
    name_file=file.split('_')[0]
    observed_data=pd.read_csv(directory+file,sep=",")
    observed_data['normalized']=minmax(observed_data, 'value')

    #plotting overall tsnr values after minmax
    fig, ax = plt.subplots( nrows=1,ncols=1)
    ax.violinplot(observed_data['normalized'], showmedians=True)
    ax.set_title("MinMax aggregated data: "+name_file)
    fig.savefig(directory+name_file+'_violinplots.png')
    #plt.close(fig)
#
    #convert 0 to Nan because log 0  -inf and replace with remaining  min
    observed_data["normalized"]=observed_data["normalized"].where(observed_data["normalized"]>0,np.nan)
    observed_data["normalized"]=observed_data["normalized"].fillna(observed_data["normalized"].min())
    #convert 1 to Nan because log 1 = 0 and replace with remaining max
    observed_data["normalized"]=observed_data["normalized"].where(observed_data["normalized"]<1,np.nan)
    observed_data["normalized"]=observed_data["normalized"].fillna(observed_data["normalized"].max())
    #getting unique methods
    data_levels=observed_data.method.unique()
    file_type=[name_file]*len(data_levels)*mcmc_sample
    bootstraped_sample=[]
    bootstrap_type=[]



#pymc3 the prior ditribution must be a beta dist 
# where alpha = 1.0 and beta =n 3.0
# which arise to the shape found in
# https://www.pymc.io/projects/docs/en/stable/api/distributions/generated/pymc.Beta.html
# likelihood may have similar shar or alpha = 2 and beta = 5
    #TODO: make a loop through the levels

    for selected_method in data_levels:

        data_subobservations=observed_data.loc[observed_data["method"] == selected_method]
        data_obs=np.array(data_subobservations["normalized"])
        bootstrap_type=bootstrap_type+([selected_method]*mcmc_sample)
        with pm.Model() as model:
            alpha=pm.Beta('alpha', alpha=2,beta=5)
            beta=pm.Beta('beta',alpha=1,beta=1)#I want to try to use a Beta as beta aprox
            Y_obs=pm.Beta('Y_obs',alpha=alpha,beta=beta,observed=data_obs)
            data=pm.sample(random_seed=7877,draws=1000,tune=2000,cores=5)
    
            #predictions=pm.sample_posterior_predictive(data,var_names=["Y_obs"],predictions=True)

        #to plot the model use: (remember we are approximating alpha and beta)
        #pm.model_to_graphviz(model)
        #to plot posterior use:
        #az.plot_posterior(data)
        #to check results from approximation use:
        summary=az.summary(data)
        # where summary 0,0 is the alpha aproximation and 0,1 our beta
        #to do posterior predictive use:
        #pm.sample_posterior_predictive(data2,model2)
        # Now we are plotting everything together
        alphas=[]
        betas=[]
        stats_observed=st.beta.fit(data_obs,floc=0,fscale=1)
        alphas.append(stats_observed[0])
        betas.append(stats_observed[1])
        #posterior_parameters=AlphaBeta(summary.iloc[0][0],summary.iloc[1][0])
        alphas.append(summary.iloc[0][0])
        betas.append(summary.iloc[1][0])
        bootstraping=np.random.beta(summary.iloc[0][0],summary.iloc[1][0],mcmc_sample)
        bootstraped_sample=bootstraped_sample+bootstraping.tolist()
        print (f"plotting likelyhood and posterior")
        plt.style.use('arviz-darkgrid')
        x_space=np.linspace(0,1,200)
        for a,b in zip(alphas,betas):
            pdf=st.beta.pdf(x_space,a,b)
            alp=f'$\alpha$={a}'
            bet=f'$\beta$={b}'
            plt.plot(x_space,pdf,label="cookies")
        plt.xlabel('Normalized tsnr values')
        plt.ylabel('Density function')
        plt.savefig(directory+name_file+selected_method+".png")
    # TODO: sample de posterior with MCMC 
    #data_array=np.column_stack(bootstraped_sample,bootstrap_type,file_type)
    data_array=list(zip(bootstraped_sample,bootstrap_type,file_type))
    df_tsnr=pd.DataFrame(data=data_array, columns=["obs","type","file"])
    df_tsnr.to_csv(directory+name_file+"_bayesian.csv",index=False)

