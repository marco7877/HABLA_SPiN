#!/usr/bin/bash
#$ -m be
#$ -M m.flores@bcbl.eu
#$ -S /bin/bash



module load python/python3.9

module load python/venv

source activate /export/home/mflores/.conda/envs/nilearn

python /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/nli2.py
