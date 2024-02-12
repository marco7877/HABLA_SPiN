#!/usr/bin/bash
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash



module load python/python3.9
module load afni/latest
module load python/venv

source activate /bcbl/home/home_g-m/mflores/conda_envs/tedana

python /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/ME-ICA_tedana.py 
