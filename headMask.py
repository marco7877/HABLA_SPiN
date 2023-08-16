"""
@author: Marco Flores-Coronado
@github: marco7877
"""
import os
import argparse

'''
Note: You should have installed AFNI in order for this code to work. Remember to run MPRAGE before,
because we will search for files ended in rebiased_clean.nii.gz
'''
####### Arguments #############################################################
parser=argparse.ArgumentParser(
        description="Creates a whole head mask from T1 uni-clean")
parser.add_argument("--bids_dir", default=None, type=str,
                    help="Full path to the BIDS directory ")
parser.add_argument("--dilate", default=3,type=int,
                    help="Dilation size to close holes within head mask")
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
args = parser.parse_args()
bids_dir=args.bids_dir
dilate=str(args.dilate)
output_dir=args.output_dir
filt_pattern=args.filt_pattern
# Here we could have a condition to check if the script has already been run and the files are there.
# Im skipping this for now
####### Reading files #########################################################
source_T1= sorted([os.path.join(root, x) for root,dirs,files in os.walk(bids_dir) 
                   for x in files if x.endswith("uniclean_T1w.nii.gz")])
if filt_pattern != None:
    source_T1=sorted([directory for directory in source_T1
                  if filt_pattern in directory])
####### Output names/dir ######################################################
output_mask= [niifti.replace("uniclean_T1w.nii.gz", "whead_mask.nii.gz") and
              niifti.replace("anat/", output_dir)
              for niifti in source_T1]
# checking if output directory exist
filenames=[ directory.partition("anat/")[0]+output_dir for directory in source_T1]
for directory in filenames:
    if not os.path.exists(directory):
        os.mkdir(directory)
del filenames
####### Head mask creation ####################################################
print("Calculating whole head mask")
for i in range(len(source_T1)):
    os.system("3dcalc" + " -a " + source_T1[i] + " -expr 'step(a-60)' " +
              " -prefix " + output_mask[i])
    os.system("3dmask_tool" + " -fill_holes -dilate_inputs " + " +" +
              dilate +" -" + dilate+ " -input "  + output_mask[i] +
              " -prefix " + output_mask[i] + " -overwrite" )

