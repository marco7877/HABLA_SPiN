#!/bin/bash


environment=/bcbl/home/home_g-m/mflores/conda_envs/pymc_env

source activate ${environment}

python /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/MCMC_tsnr.py
