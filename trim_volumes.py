"""
@author: Marco Flores-Coronado
@github: marco7877
"""
import os
import argparse
from subprocess import check_output
'''
Note: You should have installed AFNI in order for this code to work. 
This code will remove the first and the last volumes from bolf acquisitions.
First volumes are removed to wait for magnetization stabilization.
Last volumes are removed because we acquired phase
'''
####### DEBUGG
#bold_phase_ext="_part-phase_bold"
#bold_ext="_part-phase_bold"
#echoes=4
#bids_dir="/bcbl/home/public/MarcoMotion/Habla_restingState/"
#output_dir="func_preproc/"
#drop_vol=10
#drop_noise=3
####### Arguments #############################################################
parser=argparse.ArgumentParser(
        description="Creates a whole head mask from T1 uni-clean")
parser.add_argument("--echoes", default=None, type=int,
                    help="Number of echoes")
parser.add_argument("--drop_vol", default=10, type=int,
                     help="First volumes to drop")
parser.add_argument("--drop_noise", default=None, type=int,
                     help="Last noise volumes to drop")
parser.add_argument("--bids_dir", default=None, type=str,
                    help="Full path to the BIDS directory ")
parser.add_argument("--output_dir",default="func_preproc/", type =str,
                    help ="""Directory to store output at.
                    Default is func_preproc:
                        -anat
                        -func
                        -func_preproc""")
parser.add_argument("--bold_phase_ext", default="_part-phase_bold", type=str,
                    help="bold_phase name extention after **echo-{n} without .nii.gz")                        
parser.add_argument("--bold_ext", default="_part-mag_bold", type=str,
                    help="bold name extention after **echo-{n} without .nii.gz")
args = parser.parse_args()
echoes=args.echoes
bids_dir=args.bids_dir
output_dir=args.output_dir
drop_vol=args.drop_vol
drop_noise=args.drop_noise
bold_phase_ext=args.bold_phase_ext
bold_ext=args.bold_ext
####### Find files ############################################################
# Trimming both magnitude and phase niiftis
source_bold= sorted([os.path.join(root, x) 
                      for root,dirs,files in os.walk(bids_dir) 
                      for x in files if x.endswith("bold.nii.gz")])

# TODO: check if lenght bold magnitude and bold phase are the same

# Getting unique pattern
source_bold=sorted(list(set([directory.partition("echo-")[0]+"echo-"
           for directory in source_bold])))


####### Output names/dir ######################################################
output_bold= [directory.replace("func/", output_dir)
              for directory in source_bold]
# Check if output directory exists
dir_names=[ directory.partition("func/")[0]+output_dir 
           for directory in source_bold]
for directory in dir_names:
    if not os.path.exists(directory):
        os.mkdir(directory)
del dir_names
####### Trimm files ###########################################################

for i in range(len(source_bold)):
    volumes=int(check_output("3dinfo -nt "+ source_bold[i]+"1"+bold_ext+".nii.gz", shell=True))
    volumes=volumes-drop_noise-1#AFNI index starts in 0
    volumes="["+str(drop_vol)+".."+str(volumes-drop_noise)+"]'"
    for echo in range(1,echoes+1):#echoes index start in 1
        print(f"trimming" +source_bold[i]+str(echo)+bold_ext+".nii.gz")
        os.system("3dcalc -a '"+source_bold[i]+str(echo)+bold_ext+".nii.gz"+volumes+
                  " -expr 'a' -prefix "+output_bold[i]+str(echo)+bold_ext+
                  "_dsd.nii.gz" + " -overwrite")
        print(f"trimming "+source_bold[i]+str(echo)+bold_phase_ext+".nii.gz")
        os.system("3dcalc -a '"+source_bold[i]+str(echo)+bold_phase_ext+".nii.gz"+volumes+
                  " -expr 'a' -prefix "+output_bold[i]+str(echo)+bold_phase_ext+
                  "_dsd.nii.gz" + " -overwrite")
