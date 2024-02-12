"""
@author: Marco Flores-Coronado
@github: marco7877
"""
import os
import argparse

'''
Note: You should have installed AFNI in order for this code to work.
'''
####### DEBUGG
bids_dir="/bcbl/home/public/MarcoMotion/Habla_restingState/"
output_dir="func_preproc_cipactli/"
filt_pattern="func_preproc_cipactli/"
t1_ending_pattern="acq-uniclean_T1w.nii.gz"
brainmask_pattern="HABLA1200_echo-1_part-mag_sbref.nii.gz"
sbref_pattern="HABLA1200_echo-1_part-mag_sbref.nii.gz"
####### Arguments #############################################################
parser=argparse.ArgumentParser(
        description="Creates a whole head mask from T1 uni-clean")
parser.add_argument("--bids_dir", default=None, type=str,
                    help="Full path to the BIDS directory ")
parser.add_argument("--output_dir",default=None, type =str,
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
parser.add_argument("--t1_ending_pattern", default="acq-uniclean_T1w.nii.gz", type=str,
                    help="""The string pattern to identify T1W files within anat dir
                        --example: if file == sub-001_ses-1_acq-uniclean_T1w.nii.gz,
                        then, t1_ending_pattern == acq-uniclean_T1w.nii.gz
                        """)#this seems not to be necesary
parser.add_argument("--transform-matrix_pattern", default="acq-uniclean_T1w.nii.gz", type=str,
                    help="""The string pattern to identify T1W files within anat dir
                        --example: if file == sub-001_ses-1_acq-uniclean_T1w.nii.gz,
                        then, t1_ending_pattern == acq-uniclean_T1w.nii.gz
                        """)
parser.add_argument("--brainmask_pattern", default="part-mag_brain_mask.nii.gz", type=str,
                    help="""The string pattern to identify T1W files within anat dir
                        --example: if file == sub-001_ses-1_acq-uniclean_T1w.nii.gz,
                        then, t1_ending_pattern == acq-uniclean_T1w.nii.gz
                        """)
parser.add_argument("--sbref_pattern", default="HABLA1200_echo-1_part-mag_sbref.nii.gz", type=str,
                    help="""The string pattern to identify sbref files.
                         extention must include echo-1 and task to exclude more than 1 option
                        """)
args = parser.parse_args()
bids_dir=args.bids_dir
output_dir=args.output_dir
filt_pattern=args.filt_pattern
t1_ending_pattern=args.t1_ending_pattern
brainmask_pattern=args.brainmask_pattern
sbref_pattern=args.sbref_pattern
####### Start ################################################################
## load anatomical (T1w) and brain masks
source_T1= sorted([os.path.join(root, x)
                      for root,dirs,files in os.walk(bids_dir)
                      for x in files if x.endswith(t1_ending_pattern)])
source_epi_brainMask= sorted([os.path.join(root, x)
                      for root,dirs,files in os.walk(bids_dir)
                      for x in files if x.endswith(brainmask_pattern)])
target_sbref= sorted([os.path.join(root, x)
                      for root,dirs,files in os.walk(bids_dir)
                      for x in files if x.endswith(sbref_pattern)])
## filter condition THIS IS ONLY APPLIED TO BRAINMASK
if filt_pattern != None:
    source_epi_brainMask=sorted([directory for directory in source_epi_brainMask
                  if filt_pattern in directory])
    target_sbref=sorted([directory for directory in target_sbref
                  if filt_pattern in directory])
## check if output directory exists
filenames=[ source_T1[0].partition("anat/")[0]+output_dir for directory in source_T1]
for directory in filenames:
    if not os.path.exists(directory):
        os.mkdir(directory)
del filenames
## Skull stripp T1 before transformation
skullstripped_T1=[T1.replace("T1w","sk-str_T1w") for T1 in source_T1]
skullstripped_T1=[T1.replace("anat/",output_dir) for T1 in skullstripped_T1]
for i in range(len(source_T1)):
    os.system("3dSkullStrip -input "+source_T1[i]+" -prefix "+skullstripped_T1[i]+" -use_skull -no_avoid_eyes -overwrite")
## Skull stripp sbref before transformation
skullstripped_sbref=[sbref.replace("sbref","sk-str_sbref") for sbref in target_sbref]
for i in range(len(target_sbref)):
    os.system("3dSkullStrip -input "+target_sbref[i]+" -prefix "+skullstripped_sbref[i]+" -use_skull -no_avoid_eyes -overwrite")
## convert brain masks from epi to anat
# transformation matrix prefixes
sbref_filenames=[brainMask.split("/")[-1] for brainMask in target_sbref]
transform_matrix_prefix=[directory.partition("_part-mag")[0] for directory in sbref_filenames]
# target anat brain mask prefixes
target_anat_brainMask=[mask.replace("brain_mask","anat-brain_mask") for mask in source_epi_brainMask]
for i in range(len(source_T1)):
    os.chdir((source_T1[i].partition("anat/")[0]+output_dir))
    os.system("align_epi_anat.py -epi "+ skullstripped_sbref[i]+
                  " -anat "+skullstripped_T1[i]+ " -epi_base 0 -big_move -save_Al_in -anat2epi -suffix "+transform_matrix_prefix[i]+" -volreg off -tshift off -epi_strip None -anat_has_skull no -overwrite")
# Align brain mask from the epi space to the anat one
    os.system("3dAllineate -overwrite -base "+source_T1[i]+" -input "+source_epi_brainMask[i]+" -final cubic -1Dmatrix_apply "+transform_matrix_prefix[i]+"_al_mat.aff12.1D -prefix "+target_anat_brainMask[i])
## extract white and gray matter AOI from skullstripped anatomical
for i in range(len(target_anat_brainMask)):
    os.system("3dSeg -anat "+skullstripped_T1[i]+" -mask "+target_anat_brainMask[i]+" -classes 'CSF ; GM ; WM ' -bias_fwhm 25 -mixfrac UNI -blur_meth BFT")
