"""
author: Marco Flores-Coronado
@github: marco7877
"""
import os
import argparse
'''
Note: You should have installed/loaded AFNI & fsl in order for this code to work.

'''
####### DEBUGG
#bids_dir="/bcbl/home/public/MarcoMotion/Habla_restingState"
#matlab_nordic= "/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/nordic.m"
#ext_phase= "_part-phase_bold_nordic_dsd.nii.gz"
#ext_mag="_part-mag_bold_nordic_dsd.nii.gz"
#output_dir="func_preproc_nordic/"
####### Arguments #############################################################
parser=argparse.ArgumentParser(
        description="""Thermal noise removal with NORDIC
        This uses nifti files with noise volumes and without first volumes
        for magnetization""")
parser.add_argument("--bids_dir", default=None, type=str,
                    help="Full path to the BIDS directory ")
parser.add_argument("--matlab_nordic",default=None,type=str,
                    help="directory where the matlab script is allocated")
parser.add_argument("--output_dir",default="func_preproc/", type =str,
                    help ="""Directory to store output at.
                    Default is func_preproc:
                        -anat
                        -func
                        -func_preproc""")
parser.add_argument("--filt_pattern", default=None, type=str,
                    help="""The string pattern to identify specific files:
                        This is useful to parallelize subjects, e.g.:
                        --filt_pattern 001
                        or to parallelize tasks, e.g. :
                        --filt_pattern task-breathhold
                        """)
parser.add_argument("--phase_filter",default=None,type=str,help="""
			Temporal phase for nifti_nordic script""")
parser.add_argument("--ext_phase",default= "part-phase_bold_dsd.nii.gz",type=str,help="""
			Temporal phase for nifti_nordic script""")
parser.add_argument("--ext_mag",default="part-mag_bold_dsd.nii.gz",type=str,help="""
			Temporal phase for nifti_nordic script""")
parser.add_argument("--preproc_dir",default="func_preproc_nordic/",type=str,help="""
			Directory where volumes with noise, but after magnetization dropout locates""")
#parser.add_argument("--out_dir", type=str,)
args = parser.parse_args()
bids_dir=args.bids_dir
matlab_nordic=args.matlab_nordic
output_dir=args.output_dir
filt_pattern=args.filt_pattern
ext_mag=args.ext_mag
ext_phase=args.ext_phase
preproc_dir=args.preproc_dir
# Here we could have a condition to check if the script has already been run and the files are there.
# Im skipping this for now
#reading target files
####### Reading files #########################################################
# TODO: add a condition where if bold is not provided. Motion correction
# is computed from mean voxel activation from echo 1 nold.nii.gz image
source_bold= sorted([os.path.join(root, x) 
                      for root,dirs,files in os.walk(bids_dir) 
                      for x in files if x.endswith(ext_mag)])
source_phase= sorted([os.path.join(root, x) 
                      for root,dirs,files in os.walk(bids_dir) 
                      for x in files if x.endswith(ext_phase)])


## filter condition
if filt_pattern != None:
    source_bold=sorted([directory for directory in source_bold 
                  if filt_pattern in directory])
    source_phase=sorted([directory for directory in source_phase 
                  if filt_pattern in directory])

    
####### Output names/dir ######################################################
out_bold=sorted([directory.partition(preproc_dir)[-1]
           for directory in source_bold])

out_bold=[niifti.replace(".nii.gz","") for niifti in out_bold]

out_dir=sorted([directory.partition(preproc_dir)[0]+output_dir
           for directory in source_bold])

nordic=matlab_nordic.split("/")[-1]

nordic_directory=nordic[0:(len(nordic)*-1)]

#os.system("sed -i 's~code_directory~"+nordic_directory+"~' "+matlab_nordic)


for i in range(len(source_bold)):

    os.system("sed -i 's~BOLD_MAG~"+source_bold[i]+"~' "+matlab_nordic)
    
    os.system("sed -i 's~BOLD_PHASE~"+source_phase[i]+"~' "+matlab_nordic)
    
    os.system("sed -i 's~TARGET~"+out_dir[i]+"~' "+matlab_nordic)
    
    os.system("sed -i 's~FN_OUT~"+out_bold[i]+"~' "+matlab_nordic)
    
    print("matlab -batch " + '"' +"run('"+nordic+"');exit"+'"')
    
    os.system("matlab -batch " + '"' +"run('"+matlab_nordic+"');exit"+'"')
    
    os.system("sed -i 's~"+source_bold[i]+"~BOLD_MAG~' "+matlab_nordic)
   
    os.system("sed -i 's~"+source_phase[i]+"~BOLD_PHASE~' "+matlab_nordic)
    
    os.system("sed -i  's~"+out_bold[i]+"~FN_OUT~' "+matlab_nordic)
    
    os.system("sed -i  's~"+out_dir[i]+"~TARGET~' "+matlab_nordic)

