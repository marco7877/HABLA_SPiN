#!/usr/bin/bash

# remember I took out the dollar sign needed for IPS
# -m be
# -M m.flores@bcbl.eu
# -S /bin/bash

module load afni/latest
module load python/python3.9

# we are using rys script mprageize_bids.py 
python /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/mprageize_bids.py --bids_dir /bcbl/home/public/MarcoMotion/Habla_restingState  --mprageize_dir /bcbl/home/home_g-m/mflores/mytoolboxes/3dMPRAGEise --overwrite True
