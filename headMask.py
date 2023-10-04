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
####### DEBUGG
#bold_phase_ext="_part-phase_bold"
#bold_ext="_part-phase_bold"
#echoes=4
#bids_dir="/bcbl/home/public/MarcoMotion/Habla_restingState/"
#output_dir="func_preproc/"
#drop_vol=10
#drop_noise=3
####### Arguments #############################################################
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
output_mask= [niifti.replace("uniclean_T1w.nii.gz", "whead_T1mask.nii.gz")
              for niifti in source_T1]
output_mask= [niifti.replace("anat/", output_dir)for niifti in output_mask]
# checking if output directory exist
filenames=[ directory.partition("anat/")[0]+output_dir for directory in source_T1]
for directory in filenames:
    if not os.path.exists(directory):
        os.mkdir(directory)
del filenames
####### Head mask creation ####################################################
print("Calculating whole head mask")
for i in range(len(source_T1)):
    os.system("3dcalc" + " -a " + source_T1[i] + " -expr 'astep(a,70)' " +
              " -prefix " + output_mask[i] + " -overwrite")
    os.system("3dmask_tool" + " -fill_holes -dilate_inputs " + " +" +
              str(dilate) +" -" + str(dilate)+ " -input "  + output_mask[i] +
              " -prefix " + output_mask[i] + " -overwrite" )
####### Head mask trasnformation ##############################################    
source_sbref0= sorted([os.path.join(root, x) 
                      for root,dirs,files in os.walk(bids_dir) 
                      for x in files if x.endswith("echo-1_part-mag_sbref.nii.gz")])
source_sbref=sorted([x for x in source_sbref0 if "func/" in x])
sbref_names=list(set([directory.partition("func/")[-1]
                        for directory in source_sbref]))
subjects=sorted(list(set([file.split("_")[0] for file in sbref_names])))
tasks=sorted(list(set([file.split("_")[2] for file in sbref_names])))
del sbref_names
output_mask_name=[niifti.partition("acq-")[0] for niifti in output_mask]
for subject in subjects:
    target_sbref=[directory for directory in source_sbref
                  if subject in directory]
    target_T1=[directory for directory in source_T1
                  if subject in directory]
    target_mask=[directory for directory in output_mask
                  if subject in directory]
    target_mask_out=[directory for directory in output_mask_name
                  if subject in directory]
    os.chdir([target_mask_out[0].partition(output_dir)[0]+output_dir][0])
    for i in range(len(tasks)):
        tmp_mask_out=target_mask_out[0]+tasks[i]+"_echo-1_part-mag_whead_mask.nii.gz"
        print(tmp_mask_out)
        #here I changed _acq-whead_mask.nii.gz for _echo-1_part-mag_whead_mask.nii.gz
        tmp_maskAlign_ref=target_mask_out[0]+tasks[i]+"_acq-whead_mask_mcf.aff12.1D"
        os.system("align_epi_anat.py -epi "+ target_sbref[0]+
                  " -anat "+target_T1[0]+ " -epi_base mean -save_Al_in -overwrite")
        os.system("3dAllineate -overwrite -base "+target_sbref[i]+
                  " -final cubic -1Dmatrix_apply "+
                  target_mask_out[0]+"acq-uniclean_T1w_al_mat.aff12.1D"+
                  " -prefix "+ tmp_mask_out+
                  " "+target_mask[0])
        os.system("mv "+target_mask_out[0]+"acq-uniclean_T1w_al_mat.aff12.1D "+target_mask_out[0]+tasks[i]+"_acq-uniclean_T1w_al_mat.aff12.1D")
        os.system("mv "+target_mask_out[0]+"acq-uniclean_T1w_al_e2a_only_mat.aff12.1D "+target_mask_out[0]+tasks[i]+"_acq-uniclean_T1w_al_e2a_only_mat.aff12.1D")
        #os.system("rm *.1D *.BRIK *.HEAD")# This might need to be removed

