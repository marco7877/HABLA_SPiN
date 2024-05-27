#!/bin/bash



source activate /bcbl/home/home_g-m/mflores/conda_envs/bidscoin_4.0

n_sub=$1
bidscoiner -f /bcbl/home/public/MarcoMotion/4Marco /bcbl/home/public/MarcoMotion/HABLA2 -p ${n_sub}
